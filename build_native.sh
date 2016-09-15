#!/bin/bash

OS=`uname`
case $OS in
  'Darwin')
    OS='Mac OS X'
    IsMac=true
    ;;
  'WindowsNT')
    echo "Windows has a separate script build_native.ps1"
    exit 1
    ;;
  'Linux')
    IsMac=false
    ;;
  *)
    echo "$OS not supported"
    exit 1
    ;;
esac

which dialog > /dev/null
if [ $? != 0 ]; then
  echo "dialog cannot be found, please install it via apt-get or homebrew"
  exit 1
fi

if [ IsMac ]; then
  capable="OS X, iOS, and Android"
else
  capable="Android and Linux"
fi

dialog --title "Confirm" --msgbox "The detected OS is $OS.\nThis OS is capable of building $capable" 8 35

exec 3>&1
if [ IsMac ]; then
  selection=$(dialog --checklist "Choose platforms:" 10 40 3 \
    1 "OS X" on \
    2 iOS on \
    3 Android on \
    2>&1 1>&3)
else
  selection=$(dialog --checklist "Choose platforms:" 10 40 2 \
    3 Android on \
    4 Linux on \
    2>&1 1>&3)
fi
exec 3>&-

for s in $selection; do
  if [[ "$s" == "1" || "$s" == "2" ]]; then
    which xcodebuild > /dev/null
    if [ $? != 0 ]; then
      clear
      echo "xcodebuild could not be found, make sure it is present in the system path"
      exit 1
    fi
    if [[ "$s" == "1" ]]; then
      vendor/sqlite3-unicodesn/build-interop-osx.sh
      src/StorageEngines/ForestDB/CBForest/CSharp/NativeBuild/build-interop-osx.sh
    else
      vendor/sqlite3-unicodesn/build-interop-ios-fat.sh
      src/StorageEngines/ForestDB/CBForest/CSharp/NativeBuild/build-interop-ios-fat.sh
    fi
  else
    which ndk-build > /dev/null
    if [ $? != 0 ]; then
      clear
      echo "ndk-build could not be found, make sure it is present in the system path"
      exit 1
    fi
    pushd vendor/sqlite3-unicodesn
    ndk-build -j8 -C jni
    popd
    pushd src/StorageEngines/ForestDB/CBForest/CSharp/NativeBuild
    ndk-build -j8 -C jni
    cp -R libs/* ../prebuilt/
    rm -rf libs
    popd
  fi
done
