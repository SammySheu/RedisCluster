### Prepare for setting up cluster node
1. Build up folder to store seperate redis.conf and rdb file
* `bash build_folder.sh`
2. Use docker to start up Redis Node
* `docker compose up -d`
3. Utilize redis-cli to bind up redis cluster
* `bash build_cluster.sh`

