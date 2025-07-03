#!/bin/bash

export TARGET_NAME=valkey-server

# Set default ARCH if not provided
if [ -z "$ARCH" ]; then
    ARCH="amd64"
fi

# Validate supported architectures
if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ]; then
    echo "Error: Unsupported architecture '$ARCH'. Supported values are: amd64, arm64"
    exit 1
fi

echo "Building package for architecture ${ARCH}"

BASE_DOWNLOAD_URL=https://download.valkey.io/releases
PACKAGE_NAME_AMD64=valkey-8.1.2-jammy-x86_64
PACKAGE_NAME_ARM=valkey-8.1.2-jammy-arm64

cwd=$(pwd)
mkdir tmp
cp -r debian tmp/
cd tmp/debian
sed -i -e "s/###ARCH###/$ARCH/" control
cd $cwd
mkdir tmp/debian/opt

if [ "$ARCH" = "amd64" ]; then
    wget -P /tmp $BASE_DOWNLOAD_URL/$PACKAGE_NAME_AMD64.tar.gz
    PACKAGE_NAME=$PACKAGE_NAME_AMD64
else
    wget -P /tmp $BASE_DOWNLOAD_URL/$PACKAGE_NAME_ARM.tar.gz
    PACKAGE_NAME=$PACKAGE_NAME_ARM
fi

cd /tmp
tar -xvf $PACKAGE_NAME.tar.gz
cp /tmp/$PACKAGE_NAME/bin/valkey-server $cwd/tmp/debian/opt
rm -rf /tmp/valkey-8.1.2*

cd $cwd/tmp
dpkg-buildpackage --host-arch=$ARCH -us -uc

cd $cwd
mkdir -p $ARCH
mv $TARGET_NAME* $ARCH

rm -rf tmp