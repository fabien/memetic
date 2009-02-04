#!/bin/bash

pushd ${0%/*} > /dev/null
export GEM_HOME=$(pwd)/gems
popd > /dev/null

# Use a defined gem source
gem update --source http://localhost/~antony/GEM_SERVER my-app
gem clean