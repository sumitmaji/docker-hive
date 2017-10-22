#!/bin/bash

docker run -it -e ENABLE_KRB='true' -p 10001:10001 -p 10000:10000 --name hive -h hive.cloud.com --net cloud.com  sumit/hive:latest -d


