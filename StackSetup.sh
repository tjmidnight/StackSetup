#!/bin/bash

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")

#########################     Sanity Fixes     #########################
# Ensure script has sudo before doing anything.
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi
echo "DIR is: "$DIR
if [ $DIR != "/tmp" ]; then
   cd /tmp
fi

exit 0
