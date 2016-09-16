#!/bin/bash

function download_cbforest {
  dialog --clear --title "Confirm" --yesno "Do you want to download CBForest binaries?  They exist as one zip and will overwrite everything regardless of platform choice." 12 40
  if [[ $? == 0 ]]; then
    pushd src/StorageEngines/ForestDB/CBForest/CSharp/prebuilt
    wget https://github.com/couchbaselabs/cbforest/releases/download/1.3-net/1.3-CBForest-Interop.zip
    unzip 1.3-CBForest-Interop.zip -d .
    popd
  fi
}

function download_cbsqlite {
  platform=$1
  pushd src/StorageEngines/CustomSQLite/vendor/sqlite
  if [[ "$platform" == "1" ]]; then
    echo "Downloading libcbsqlite3.dylib (OS X)"
    curl -L https://github.com/couchbase/couchbase-lite-java-native/raw/master/vendor/sqlite/libs/osx/libsqlite3.dylib -o libcbsqlite3.dylib
  elif [[ "$platform" == "2" ]]; then
    echo "Downloading x86/cbsqlite3.dll (Windows)"
    curl -L https://github.com/couchbase/couchbase-lite-java-native/raw/master/vendor/sqlite/libs/windows/x86/sqlite3.dll -o x86/cbsqlite3.dll
    echo "Downloading x64/cbsqlite3.dll (Windows)"
    curl -L https://github.com/couchbase/couchbase-lite-java-native/raw/master/vendor/sqlite/libs/windows/x86_64/sqlite3.dll -o x64/cbsqlite3.dll
  elif [[ "$platform" == "3" ]]; then
    echo "Downloading libcbsqlite.so (Linux 64-bit)"
    curl -L https://github.com/couchbase/couchbase-lite-java-native/raw/master/vendor/sqlite/libs/linux/x86_64/libsqlite3.so -o libcbsqlite3.so
  elif [[ "$platform" == "4" ]]; then
    echo "Downloading libsqlite3.a (iOS)"
    curl -LO https://github.com/couchbase/couchbase-lite-java-native/raw/master/vendor/sqlite/libs/ios/libsqlite3.a
  else
    mkdir arm64-v8a armeabi armeabi-v7a x86 x86_64 x64 2> /dev/null
    ANDROID_FILENAMES=(arm64-v8a/libsqlite3.so armeabi/libsqlite3.so armeabi-v7a/libsqlite3.so x86/libsqlite3.so x86_64/libsqlite3.so)
    for filename in ${ANDROID_FILENAMES[@]}; do
      final_filename=${filename/sqlite/cbsqlite}
      echo "Downloading $filename (Android)"
      curl -L https://github.com/couchbase/couchbase-lite-java-native/raw/master/vendor/sqlite/libs/android/$filename -o $final_filename
    done
  fi
  popd
}

function download {
  lib_name=$1
  platform=$2

  if [[ "$lib_name" == "S" ]]; then
    download_cbsqlite $platform
  fi
}

which dialog > /dev/null
if [ $? != 0 ]; then
  echo "dialog cannot be found, please install it via apt-get or homebrew"
  exit 1
fi

exec 3>&1
libs=$(dialog --clear --checklist "Choose libs to download:" 10 40 2 \
  F CBForest-Interop on \
  S "Custom SQLite" on \
  2>&1 1>&3)

if [[ $? != 0 ]]; then
  exit
fi

platforms=$(dialog --clear --checklist "Choose platforms:" 12 40 5 \
  1 "OS X" on \
  2 Windows on \
  3 Linux on \
  4 iOS on \
  5 Android on \
  2>&1 1>&3)

if [[ $? != 0 ]]; then
  exit
fi
exec 3>&-

for l in $libs; do
  if [[ "$l" == "F" ]]; then
    download_cbforest
  else
    for p in $platforms; do
      download $l $p
    done
  fi
done
