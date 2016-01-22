#!/bin/sh
"echo '---get skynet---'"
"git submodule update --init"

echo "---make skynet---"
cd 3rd/skynet
make cleanall
make linux

echo "---make self---"
cd ../..
make clean
make linux
