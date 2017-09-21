#!/bin/bash

docker run -d -p 10001:10001 -p 10000:10000 --name hive -h hive --net cloud.com  sumit/hive:latest /etc/bootstrap.sh -d


