#!/bin/bash
# First parameter must be the build2 'bdep' binary that
# should be used.
BDEP="${1}"

# Following the suggestions from https://github.com/build2/HOWTO/blob/master/entries/handle-tests-with-extra-dependencies.md

echo "This script adds a new library with a separate package for unit testing."
echo "Please enter the name of the library to be created: "

read library

${BDEP} new -t empty -s none ${library}
pushd ${library}

${BDEP} new --package -l c++ -t lib -s none ${library}
${BDEP} new --package -l c++ -t exe -s none ${library}-tests

popd

echo "Please review the newly created packages and adapt their configuration as necessary."