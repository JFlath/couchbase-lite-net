// 
// Copyright (c) 2014 .NET Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
// Copyright (c) 2014 Couchbase, Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
// except in compliance with the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions
// and limitations under the License.
//using System;
using Couchbase.Lite.Support;
using Couchbase.Lite.Util;
using Sharpen;

namespace Couchbase.Lite.Support
{
    public class Version
    {
        public static readonly string Version;

        private const string VersionName = "${VERSION_NAME}";

        private const string VersionCode = "${VERSION_CODE}";

        static Version()
        {
            // replaced during build process
            // replaced during build process
            Version = string.Format("%s-%s", GetVersionName(), GetVersionCode());
        }

        public static string GetVersionName()
        {
            if (VersionName == "${VERSION_NAME}")
            {
                return "devbuild";
            }
            return VersionName;
        }

        public static int GetVersionCode()
        {
            if (VersionCode == "${VERSION_CODE}")
            {
                return 0;
            }
            try
            {
                System.Convert.ToInt32(VersionCode);
            }
            catch (FormatException)
            {
                Log.E(Log.Tag, "Cannot parse version code: %s", VersionCode);
            }
            return -1;
        }

        public static string GetVersion()
        {
            return string.Format("%s-%s", GetVersionName(), GetVersionCode());
        }
    }
}
