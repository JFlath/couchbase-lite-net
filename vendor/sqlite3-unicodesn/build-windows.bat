@echo off
setlocal ENABLEEXTENSIONS

IF NOT DEFINED VS140COMNTOOLS (
    echo You must have Visual Studio 2015 installed
    exit /b 1
)

pushd "%~dp0"
call "%VS140COMNTOOLS%VCVarsQueryRegistry.bat"

set BIN32=%VS140COMNTOOLS%..\..\vc\bin
set BIN64=%VS140COMNTOOLS%..\..\vc\bin\amd64
set SQLITE3_PATH=..\..\src\StorageEngines\ForestDB\CBForest\vendor\sqlite3-unicodesn\
set CBFOREST_WIN_PATH=..\..\src\StorageEngines\ForestDB\CBForest\CBForest.VS2015

mkdir x86
mkdir x64

"%BIN32%\cl.exe" /MT^
 /I "%VS140COMNTOOLS%..\..\vc\include"^
 /I "%UniversalCRTSdkDir%include\%UCRTVersion%\ucrt"^
 /I %CBFOREST_WIN_PATH%^
 /I %SQLITE3_PATH%^
 /I "%SQLITE3_PATH%\libstemmer_c\runtime"^
 /D SQLITE_ENABLE_FTS4^
 /D SQLITE_ENABLE_FTS4_UNICODE61^
 /D WITH_STEMMER_english^
 "%SQLITE3_PATH%\fts3_unicode2.c"^
 "%SQLITE3_PATH%\fts3_unicodesn.c"^
 "%SQLITE3_PATH%\libstemmer_c\runtime\*.c"^
 "%SQLITE3_PATH%\libstemmer_c\src_c\*.c"^
 "%CBFOREST_WIN_PATH%\..\CBForest\sqlite_glue.c"^
 /link^
 /libpath:"%VS140COMNTOOLS%..\..\vc\lib"^
 /libpath:"%UniversalCRTSdkDir%lib\%UCRTVersion%\ucrt\x86"^
 /libpath:"%WindowsSdkDir%lib\%WindowsSDKLibVersion%um\x86"^
 /export:sqlite3Fts3UnicodeSnTokenizer^
 /export:sqlite3FtsUnicodeIsalnum^
 /DLL^
 /OUT:x86\Tokenizer.dll
 
 del *.obj
 
"%BIN64%\cl.exe" /MT^
 /I "%VS140COMNTOOLS%..\..\vc\include"^
 /I "%UniversalCRTSdkDir%include\%UCRTVersion%\ucrt"^
 /I %CBFOREST_WIN_PATH%^
 /I %SQLITE3_PATH%^
 /I "%SQLITE3_PATH%\libstemmer_c\runtime"^
 /D SQLITE_ENABLE_FTS4^
 /D SQLITE_ENABLE_FTS4_UNICODE61^
 /D WITH_STEMMER_english^
 "%SQLITE3_PATH%\fts3_unicode2.c"^
 "%SQLITE3_PATH%\fts3_unicodesn.c"^
 "%SQLITE3_PATH%\libstemmer_c\runtime\*.c"^
 "%SQLITE3_PATH%\libstemmer_c\src_c\*.c"^
 "%CBFOREST_WIN_PATH%\..\CBForest\sqlite_glue.c"^
 /link^
 /libpath:"%VS140COMNTOOLS%..\..\vc\lib\amd64"^
 /libpath:"%UniversalCRTSdkDir%lib\%UCRTVersion%\ucrt\x64"^
 /libpath:"%WindowsSdkDir%lib\%WindowsSDKLibVersion%um\x64"^
 /export:sqlite3Fts3UnicodeSnTokenizer^
 /export:sqlite3FtsUnicodeIsalnum^
 /DLL^
 /OUT:x64\Tokenizer.dll
 
 del *.obj
 popd