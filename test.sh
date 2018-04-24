#!/usr/bin/env bash

DIR=$(dirname $0)
YAML="$DIR/.travis.yml"

while read CMD
do
  echo "### START TEST: $CMD"
  bash -c "$CMD"
  echo "### TEST RESULT: $?"
  echo "### END TEST"
#  $$CMD
done < <(grep sixess "$YAML" | sed 's/^[^"]*"//' | sed 's/"$//')
