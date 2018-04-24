#!/usr/bin/env bash

# this reads the script: section of the .travis.yml file
# and runs all the tests locally instead
# can run from root directory with: ./test.sh |& grep '###'

DIR=$(dirname $0)
YAML="$DIR/.travis.yml"

while read CMD
do
  echo "### START TEST: $CMD"
  bash -c "$CMD"
  echo "### TEST RESULT: $?"
  echo "### END TEST"
done < <(grep sixess "$YAML" | sed 's/^[^"]*"//' | sed 's/"$//')
