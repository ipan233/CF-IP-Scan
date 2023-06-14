#!/bin/bash
# Path: entrypoint.sh
# check system is arm64 or amd64
if [ $(uname -m) == "aarch64" ]; then
    echo "当前系统是arm64架构"
    # BEGIN: ed8c6549bwf9
    cp -f asscan_linux_arm64/iptest iptest
else
    echo "当前系统是amd64架构"
    cp -f asscan_linux_amd64/iptest iptest
fi
# run asscan.sh and autoddns.sh
bash asscan.sh && bash autoddns.sh
tail -f /dev/null
