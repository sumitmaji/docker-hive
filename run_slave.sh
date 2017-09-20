#!/bin/bash

docker run -d -p 56000-56020:56000-56020 -p 10000:10000 -p 50075:50075 -p 50010:50010 -p 444:44444 -p 2122:2122 -p 50070:50070 -p 54310:54310 --name slave01 -h slave01 --net cloud.com  sumit/hive:latest /etc/bootstrap.sh -d slave


