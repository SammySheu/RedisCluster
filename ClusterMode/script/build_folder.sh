for port in `seq 8001 8006`; do \
mkdir -p ./${port} \
&& PORT=${port} envsubst < ./config/redis-cluster.tmpl > ./${port}/redis.conf \
&& mkdir -p ./${port}/data \
# && echo "" > /var/log/redis${port}.log; \
done
