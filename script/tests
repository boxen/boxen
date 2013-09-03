#!/bin/sh
# Run the unit tests.

cd "$(dirname $0)"/..

script/bootstrap &&
  ruby -rubygems -Ilib:test \
    -e 'require "bundler/setup"' \
    -e 'tests = ARGV.empty? ? Dir["test/**/*_test.rb"] : ARGV' \
    -e 'tests.each { |f| load f }' "$@"
