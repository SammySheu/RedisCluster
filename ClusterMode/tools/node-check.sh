#!/bin/bash
#esc=$(echo -e "\x1B")
#enter=$(echo -e "\n")

user=sammy
pass=aaf5ad63ac417e5002bdac202e07287cf90f35b1d419464d2c4fc79e508a1e4c
redis_ip=192.168.1.168
redis_port=8001

echo "check from $redis_ip : $redis_port"

read -n1 -p "cluster nodes [M]aster or [S]lave or [A]ll : " res

case $res in
    M|m)
	echo ""
        redis-cli -c -h $redis_ip -p $redis_port --user $user --pass $pass CLUSTER NODES | grep 'master' | awk  -F ' '  '{print " "$1" "$2" "$3}' ;;
    S|s)
	echo ""
	    redis-cli -c -h $redis_ip -p $redis_port --user $user --pass $pass CLUSTER NODES | grep 'slave' | awk  -F ' '  '{print " "$1" "$2" "$3}' ;;
    A|a)
	echo ""
        redis-cli -c -h $redis_ip -p $redis_port --user $user --pass $pass CLUSTER NODES | awk  -F ' '  '{print " "$1" "$2" "$3}' | sort -bk2,18 ;;

    $'\e')
        echo ""
	echo "...quit..."
        exit ;;
    *)
        echo "Unknow options($res)" ;;
esac

echo ""
echo "...End..."

