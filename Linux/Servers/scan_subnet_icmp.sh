#!/bin/bash
#Copyright (c) 2021 George Ziongkas





ipAddress=192.168.1


if [ ! -d "pingresult.txt" ]; then 
    echo "file exists" 
else
    touch pingresult.txt
fi

for i in {1..255} ;do 
(
    {
    ping -w 1 $ipAddress.$i ; 
    result=$(echo $?);
    } &> /dev/null
    if [ $result = 0 ]; then
        echo Successful Ping From : $ipAddress.$i >> pingresult.txt
    fi &);
done
