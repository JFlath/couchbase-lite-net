#!/bin/bash

function validate_platform {
  platform=$1

  if [[ "$platform" == "O" || "$platform" == "I" ]]; then
    which xcodebuild > /dev/null
    if [ $? != 0 ]; then
      clear
      echo "xcodebuild could not be found, make sure it is present in the system path"
      exit 1
    fi
  elif [[ "$platform" == "A" ]]; then
    which ndk-build > /dev/null
    if [ $? != 0 ]; then
      clear
      echo "ndk-build could not be found, make sure it is present in the system path"
      exit 1
    fi 
  else
    which make > /dev/null
    if [ $? != 0 ]; then
      clear
      echo "make could not be found, make sure it is present in the system path"
      exit 1
    fi
  fi
}

function build_osx {
  lib_name=$1

  if [[ "$lib_name" == "1" ]]; then
    src/StorageEngines/ForestDB/CBForest/CSharp/NativeBuild/build-interop-osx.sh
  else
    vendor/sqlite3-unicodesn/build-interop-osx.h
  fi
}

function build_ios {
  if [[ "$lib_name" == "1" ]]; then
    src/StorageEngines/ForestDB/CBForest/CSharp/NativeBuild/build-interop-ios-fat.sh
  else
    vendor/sqlite3-unicodesn/build-interop-ios-fat.sh
  fi
}

function build_droid {
  if [[ "$lib_name" == "1" ]]; then
    pushd src/StorageEngines/ForestDB/CBForest/CSharp/NativeBuild
    ndk-build -j8 -C jni
    cp -R libs/* ../prebuilt/
    rm -rf libs
    popd
  else
    pushd vendor/sqlite3-unicodesn
    ndk-build -j8 -C jni
    popd
  fi
}

function build_linux {
  if [[ "$lib_name" == "1" ]]; then
    pushd src/StorageEngines/ForestDB/CBForest/CSharp/NativeBuild
    make clean
    make
    make install
    popd· 
  else
    pushd vendor/sqlite3-unicodesn
    make clean
    make
    popd
  fi
}

function build {
  lib_name=$1
  platform=$2

  echo $platform
  case $platform in
    'O')
      build_osx $1
      ;;
    'I')
      build_ios $1
      ;;
    'A')
      build_droid $1
      ;;
    'L')
      build_linux $1
      ;;
    *)
      echo "I don't know what to do!"
      ;;
  esac
}

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

if $IsMac ; then
  capable="OS X, iOS, and Android"
else
  capable="Android and Linux"
fi

dialog --title "Confirm" --msgbox "The detected OS is $OS.\nThis OS is capable of building $capable" 8 35

exec 3>&1
libs=$(dialog --clear --checklist "Choose libs to build:" 10 40 2 \
  1 CBForest-Interop on \
  2 Tokenizer on \
  2>&1 1>&3)

if [[ $? != 0 ]]; then
  exit
fi

if $IsMac ; then
  platforms=$(dialog --clear --checklist "Choose platforms:" 10 40 3 \
    O "OS X" on \
    I iOS on \
    A Android on \
    2>&1 1>&3)
else
  platforms=$(dialog --clear --checklist "Choose platforms:" 10 40 2 \
    A Android on \
    L Linux on \
    2>&1 1>&3)
fi

if [[ $? != 0 ]]; then
  exit
fi
exec 3>&-

for p in $platforms; do
  validate_platform $p
  for l in $libs; do
    build $l $p
  done
done
