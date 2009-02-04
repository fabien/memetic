#!/bin/bash

pushd ${0%/*} > /dev/null
export GEM_HOME=$(pwd)/gems
popd > /dev/null

ruby -e 'require "my-app"' -e 'MyApp.start'