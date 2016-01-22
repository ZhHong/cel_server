#!/bin/sh

echo "---update skynet---"
cd 3rd/skynet
git checkout master
git pull -v --progress
cd ../..
echo "---update skyserver---"
git checkout master
git pull -v --progress


