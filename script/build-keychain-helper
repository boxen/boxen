#!/bin/sh

set -e

cd $(dirname "$0")/..
cc -g -O2 -Wall -framework Security -framework CoreFoundation -mmacosx-version-min=10.6 -o script/Boxen src/keychain-helper.c
