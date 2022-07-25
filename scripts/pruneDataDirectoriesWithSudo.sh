#!/bin/bash
# Get the path of the root of the project. It could be called from anywhere, so use this to get full paths.
# Assumes that this script lives in a directory, which lives in the root.
ROOTPATH="$( cd "$(dirname "$0")/.."; pwd -P )"

find "$ROOTPATH" -name _data -type d -prune -exec sudo rm -rf {} \;
