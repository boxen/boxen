#!/bin/sh
# Tag and push a release.

set -e

# Make sure we're in the project root.

cd $(dirname "$0")/..

# Build a new gem archive.

rm -rf boxen-*.gem
gem build -q boxen.gemspec

# Make sure we're on the master branch.

(git branch | grep -q '* master') || {
  echo "Only release from the master branch."
  exit 1
}

# Figure out what version we're releasing.

tag=v`ls boxen-*.gem | sed 's/^boxen-\(.*\)\.gem$/\1/'`

# Make sure we haven't released this version before.

git fetch -t origin

(git tag -l | grep -q "$tag") && {
  echo "Whoops, there's already a '${tag}' tag."
  exit 1
}

# Tag it and bag it.

gem push boxen-*.gem && git tag "$tag" &&
  git push origin master && git push origin "$tag"
