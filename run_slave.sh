#!/bin/bash

docker run --name consul -h $HOSTNAME      -p 8300:8300 -p 8301:8301       -p 8301:8301/udp   -p 8302:8302      -p 8302:8302/udp   -p 8400:8400       -p 8500:8500       -p 53:53/udp      -d progrium/consul -server -advertise 11.0.0.4 -join 11.0.0.2

docker run -d -v /var/run/docker.sock:/tmp/docker.sock --link consul:consul --name registrator -h registrator gliderlabs/registrator:latest consul://11.0.0.4:8500

docker run -d -p 50010:50010 -p 444:44444 -p 2122:2122 -p 50070:50070 -p 54310:54310 --dns 172.17.0.2 --dns 8.8.8.8 --dns-search service.consul -e "SERVICE_2122_NAME=node03" -e "SERVICE_2122_ID=node03.2122" --name hive -h node03 sumit/hive:latest /etc/bootstrap.sh -d slave


