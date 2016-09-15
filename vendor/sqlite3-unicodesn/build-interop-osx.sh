#!/bin/bash

set -e

pushd `dirname $0`
OUTPUT_DIR=`pwd`
popd

rm -f $OUTPUT_DIR/libTokenizer.dylib
pushd $OUTPUT_DIR/../../src/StorageEngines/ForestDB/CBForest/
rm -rf $OUTPUT_DIR/build
xcodebuild -scheme "Tokenizer-Interop" -configuration Release -derivedDataPath $OUTPUT_DIR/build clean build

mv $OUTPUT_DIR/build/Build/Products/Release/libTokenizer.dylib $OUTPUT_DIR/libTokenizer.dylib

rm -rf $OUTPUT_DIR/build
popd
