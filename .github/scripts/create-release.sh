#!/usr/bin/env bash

set -e

VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "Invalid Version: $0"
    exit 1
fi

RELEASE_DIR="release/release-$VERSION"
SCRIPT_DIR="$RELEASE_DIR/reframework/autorun"

rm -rf release
mkdir -p "$SCRIPT_DIR"

cp "HOW TO INSTALL.txt" "$RELEASE_DIR/"
cp ChargeBladeResurgence.lua "$SCRIPT_DIR/"
cp -R ChargeBladeResurgenceDependencies "$SCRIPT_DIR/"

cd "$RELEASE_DIR"
zip -r "../Charge Blade Resurgence $VERSION.zip" .
