#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi
if [ $DIR != "/tmp" ]; then
   cd /tmp
fi
wget https://raw.githubusercontent.com/tjspann/StackSetup/experimental/master.sh
chmod +x /tmp/master.sh
/bin/bash /tmp/master.sh

exit 0
