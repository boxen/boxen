#!/bin/sh
# Make sure local dependencies are satisfied.

cd "$(dirname $0)"/..

rm -f .bundle/config
bundle install --binstubs bin --path .bundle --quiet
