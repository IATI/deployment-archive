#!/bin/bash
# roles/common/openssl_install/files/install.sh

wget https://www.openssl.org/source/openssl-1.1.0-latest.tar.gz -O /tmp/openssl-1.1.0-latest.tar.gz

cd /tmp
tar -xvzf openssl-1.1.0-latest.tar.gz

cd openssl-1.0.1g

./config --prefix=/usr         \
  --openssldir=/etc/ssl \
  --libdir=lib          \
  shared                \
  zlib-dynamic

make install

make clean

cd ..

rm -rf openssl-1.1.0-latest.tar.gz openssl-1.1.0-latest/
