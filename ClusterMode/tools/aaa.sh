#!/bin/bash

REDIS_IP=192.168.1.250
REDIS_PORT=7001


# master映射表，key为master的id，value为master的“ip:port”
declare -A master_map=()
# slave映表，key为master的id，value为slave的“ip:port”
declare -A slave_map=()
master_nodes_str=
master_slave_maps_str=

    masters=`redis-cli -h $REDIS_IP -p $REDIS_PORT CLUSTER NODES | awk -F[\ \@] '/master/{ printf("%s,%s\n",$1,$2); }' | sort`

for master in $masters;
do    
    eval $(echo $master | awk -F[,] '{ printf("master_id=%s\nmaster_node=%s\n",$1,$2); }')

    master_map[$master_id]=$master_node    
    if test -z "$master_nodes_str"; then
        master_nodes_str="$master_node|$master_id"
    else
        master_nodes_str="$master_node|$master_id,$master_nodes_str"
    fi
done

    slaves=`redis-cli -h $REDIS_IP -p $REDIS_PORT CLUSTER NODES | awk -F[\ \@] '/slave/{ if (NF==9) printf("%s,%s\n",$5,$2); else printf("%s,%s\n",$4,$2); }' | sort`

for slave in $slaves;
do
    eval $(echo $slave | awk -F[,] '{ printf("master_id=%s\nslave_node=%s\n",$1,$2); }')
    slave_map[$master_id]=$slave_node
done

for key in ${!master_map[@]}
do
    master_node=${master_map[$key]}
    slave_node=${slave_map[$key]}

    if test -z "$master_slave_maps_str"; then
        master_slave_maps_str="$slave_node|$master_node"
    else
        master_slave_maps_str="$slave_node|$master_node,$master_slave_maps_str"
    fi
done

# 显示所有master
index=1
old_master_node_ip=
master_nodes_str=`echo "$master_nodes_str" | tr ',' '\n' | sort`
for master_node_str in $master_nodes_str;
do
    eval $(echo "$master_node_str" | awk -F[\|] '{ printf("master_node=%s\nmaster_id=%s\n", $1, $2); }')
    eval $(echo "$master_node" | awk -F[\:] '{ printf("master_node_ip=%s\nmaster_node_port=%s\n", $1, $2); }')

    tag=
    # 同一IP上出现多个master，标星
    if test "$master_node_ip" = "$old_master_node_ip"; then
        tag="  (*)"
    fi

    printf "[%02d][MASTER]  %-20s \033[0;32;31m%s\033[m%s\n" $index "$master_node" "$master_id" "$tag"
    old_master_node_ip=$master_node_ip
    index=$((++index))
done

# 显示所有slave到master的映射
index=1
echo ""
master_slave_maps_str=`echo "$master_slave_maps_str" | tr ',' '\n' | sort`
for master_slave_map_str in $master_slave_maps_str;
do
    eval $(echo "$master_slave_map_str" | awk -F[\|] '{ printf("slave_node=%s\nmaster_node=%s\n", $1, $2); }')
    eval $(echo "$slave_node" | awk -F[\:] '{ printf("slave_node_ip=%s\nslave_node_port=%s\n", $1, $2); }')
    eval $(echo "$master_node" | awk -F[\:] '{ printf("master_node_ip=%s\nmaster_node_port=%s\n", $1, $2); }')

    tag=
    # 一对master和slave出现在同一IP，标星
    if test ! -z "$slave_node_ip" -a "$slave_node_ip" = "$master_node_ip"; then
        tag="  (*)"
    fi

    n=$(($index % 2))
    if test $n -eq 0; then
        printf "[%02d][SLAVE=>MASTER] \033[1;33m%21s\033[m  =>  \033[1;33m%s\033[m%s\n" $index $slave_node $master_node "$tag"
    else
        printf "[%02d][SLAVE=>MASTER] %21s  =>  %s%s\n" $index $slave_node $master_node "$tag"
    fi

    index=$((++index))
done

echo ""
exit 0
