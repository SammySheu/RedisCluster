#!/bin/bash

user=sammy
pass=aaf5ad63ac417e5002bdac202e07287cf90f35b1d419464d2c4fc79e508a1e4c
dockern=redis-p1

p1_port=8001
p2_port=8002
p3_port=8003
p4_port=8004
p5_port=8005
p6_port=8006

REDIS_CLUSTER1_IP="192.168.1.168"
echo 'yes' | docker exec -i $dockern \
	redis-cli --cluster create \
	$REDIS_CLUSTER1_IP:$p1_port \
	$REDIS_CLUSTER1_IP:$p2_port \
	$REDIS_CLUSTER1_IP:$p3_port \
	$REDIS_CLUSTER1_IP:$p4_port \
	$REDIS_CLUSTER1_IP:$p5_port \
	$REDIS_CLUSTER1_IP:$p6_port \
	--cluster-replicas 1 \
	-u $sammy \
	-a $pass
