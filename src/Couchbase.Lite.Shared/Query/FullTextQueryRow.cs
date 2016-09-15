//
// FullTextQuery.cs
//
// Author:
// 	Jim Borden  <jim.borden@couchbase.com>
//
// Copyright (c) 2016 Couchbase, Inc All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Couchbase.Lite.Internal;
using Couchbase.Lite.Store;
using Couchbase.Lite.Support;
using Couchbase.Lite.Util;

namespace Couchbase.Lite
{
    public sealed class FullTextQueryRow : QueryRow
    {
        private const string Tag = nameof(FullTextQueryRow);

        private readonly ulong _fullTextID;
        private List<FTSMatch> _matches = new List<FTSMatch>(4);

        /// <summary>
        /// Gets the text emitted when the view was indexed (the TextKey object) which contains the
        /// match(es).
        /// </summary>
        public string FullText
        {
            get {
                var fullTextData = GetFullTextData();
                return fullTextData == null ? null : Encoding.UTF8.GetString(fullTextData);
            }
        }

        /// <summary>
        /// Gets the number of query words that were found in the fullText.
        /// (If a query word appears more than once, only the first instance is counted.)
        /// </summary>
        public uint MatchCount 
        {
            get {
                return (uint)_matches.Count;
            }
        }

        internal string Snippet { get; set; }

        internal FullTextQueryRow(string documentId, long sequence, ulong fullTextID, object value)
         : base(documentId, sequence, null, value, null)
        {
            _fullTextID = fullTextID;
        }


        /// <summary>
        /// Returns a short substring of the full text containing at least some of the matched words.
        /// This is useful to display in search results, and is faster than fetching the.fullText.
        /// NOTE: The "FullTextSnippets" property of the Query must be set to YES to enable this;
        /// otherwise the result will be null.
        /// </summary>
        /// <returns>The snippet.</returns>
        /// <param name="wordStart">A delimiter that will be inserted before every instance of a match.</param>
        /// <param name="wordEnd">A delimiter that will be inserted after every instance of a match.</param>
        public string GetSnippet(string wordStart, string wordEnd)
        {
            if(Snippet != null) {
                var sb = new StringBuilder(Snippet);
                sb.Replace("\001", wordStart);
                sb.Replace("\002", wordEnd);
                return sb.ToString();
            } else {
                // Generate the snippet myself. This is pretty crude compared to SQLite's algorithm,
                // which is described at http://sqlite.org/fts3.html#section_4_2
                var fullText = FullText;
                if(fullText == null) {
                    return String.Empty;
                }

                var tokenRanges = GetWordRanges(fullText);
                if(!tokenRanges.Any()) {
                    return null;
                }

                // Find the indexes (in tokenRanges) of the first and last match:
                //FIX: It would be better to find a region that includes as many matches as possible.
                var start = GetTextRange(0).Location;
                var end = MaxRange(GetTextRange(MatchCount - 1));
                var startTokenIndex = -1;
                var endTokenIndex = -1;
                var i = 0;
                foreach(var range in tokenRanges) {
                    if(startTokenIndex < 0 && range.Location >= start) {
                        startTokenIndex = i;
                    }

                    endTokenIndex = i;
                    if(MaxRange(range) >= end) {
                        break;
                    }

                    i++;
                }

                // Try to get exactly the desired number of tokens in the snippet by adjusting start/end:
                const int MaxTokens = 15;
                var addTokens = MaxTokens - (endTokenIndex - startTokenIndex + 1);
                if(addTokens > 0) {
                    startTokenIndex -= Math.Min(addTokens / 2, startTokenIndex);
                    endTokenIndex = Math.Min(startTokenIndex + MaxTokens, tokenRanges.Count - 1);
                    startTokenIndex = Math.Max(0, endTokenIndex - MaxTokens);
                } else {
                    endTokenIndex += addTokens;
                }

                if(startTokenIndex > 0) {
                    startTokenIndex--; // start the snippet one word before the first match
                }

                // Update the snippet character range to the ends of the tokens:
                var prefix = String.Empty;
                var suffix = String.Empty;

                if(startTokenIndex > 0) {
                    start = tokenRanges[startTokenIndex].Location;
                    prefix = "…";
                } else {
                    start = 0;
                }

                if(endTokenIndex < tokenRanges.Count - 1) {
                    end = MaxRange(tokenRanges[endTokenIndex]);
                    suffix = "…";
                } else {
                    end = fullText.Length;
                }

                var snippet = new StringBuilder(fullText.Substring(start, end - start));

                // Wrap matches with caller-supplied strings:
                if(!String.IsNullOrEmpty(wordStart) || !String.IsNullOrEmpty(wordEnd)) {
                    var delta = -start;
                    for(var idx = 0U; idx < MatchCount; idx++) {
                        var range = GetTextRange(idx);
                        if(range.Location >= start && MaxRange(range) <= end) {
                            if(!String.IsNullOrEmpty(wordStart)) {
                                snippet.Insert(range.Location + delta, wordStart);
                                delta += wordStart.Length;
                            }

                            if(!String.IsNullOrEmpty(wordEnd)) {
                                snippet.Insert(MaxRange(range) + delta, wordEnd);
                                delta += wordEnd.Length;
                            }
                        }
                    }
                }

                // Add ellipses at start/end if necessary:
                snippet.Insert(0, prefix);
                snippet.Append(suffix);
                return snippet.ToString();
            }
        }

        /// <summary>
        /// Gets the character range in the fullText of a particular match.
        /// </summary>
        /// <returns>The character range.</returns>
        /// <param name="matchNumber">The match to check for</param>
        public Range GetTextRange(uint matchNumber)
        {
            var match = _matches[(int)matchNumber];
            var byteStart = match.TextRange.Location;
            var byteLength = match.TextRange.Length;
            var rawText = GetFullTextData();
            if(rawText == null) {
                return new Range(Range.NotFound, 0);
            }

            Func<byte[], int, int, int> cc = Encoding.UTF8.GetCharCount;
            return new Range(cc(rawText, 0, byteStart), cc(rawText, byteStart, byteLength));
        }

        /// <summary>
        /// Gets the index of the search term matched by a particular match. Search terms are the individual 
        /// words in the full-text search expression, skipping duplicates and noise/stop-words.They're
        /// numbered from zero.
        /// </summary>
        /// <returns>The term index.</returns>
        /// <param name="matchNumber">The match number to check for</param>
        public uint GetTermIndex(uint matchNumber)
        {
            return _matches[(int)matchNumber].Term;
        }

        internal void AddTerm(uint term, Range range)
        {
            var match = new FTSMatch { Term = term, TextRange = range };
            _matches.Add(match);
        }

        private byte[] GetFullTextData()
        {
            var storage = Storage;
            if(storage == null) {
                Log.To.Query.W(Tag, "Cannot get the fullText, the database is gone");
                return null;
            }

            return storage.FullTextForDocument(DocumentId, SequenceNumber, _fullTextID);
        }

        private static List<Range> GetWordRanges(string input)
        {
            var retVal = new List<Range>();
            var location = 0;
            var length = 0;
            foreach(var c in input) {
                if(!Char.IsLetterOrDigit(c)) {
                    if(length != 0) {
                        retVal.Add(new Range(location, length));
                    }

                    length = 0;
                } else {
                    length += 1;
                }

                location += 1;
            }

            return retVal;
        }

        private static int MaxRange(Range range)
        {
            return range.Location + range.Length;
        }
    }
}
