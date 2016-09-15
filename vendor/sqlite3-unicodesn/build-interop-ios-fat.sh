#!/bin/bash

set -e

pushd `dirname $0`
OUTPUT_DIR="`pwd`"
popd

rm -f $OUTPUT_DIR/libTokenizer.a

pushd $OUTPUT_DIR/../../src/StorageEngines/ForestDB/CBForest
rm -rf build
xcodebuild -scheme "Tokenizer-Interop Static" -configuration Release -derivedDataPath build -sdk iphoneos
xcodebuild -scheme "Tokenizer-Interop Static" -configuration Release -derivedDataPath build -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=latest'

lipo -create -output $OUTPUT_DIR/libTokenizer.a build/Build/Products/Release-iphoneos/libTokenizer.a build/Build/Products/Release-iphonesimulator/libTokenizer.a

rm -rf build
popd
