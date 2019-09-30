#!/bin/bash

if [ -n "$1" ]; then
    echo "$1"
else
    echo "No"
    exit
fi

ansible all -b -m yum -a "name=$1 state=present"