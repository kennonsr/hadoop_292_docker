# hadoop_292_docker

Docker for standalone and pseudo-distributed mode

# Build and run Hadoop Docker

`docker build -t hadoop_292 .`

`docker run -t -i -d -p 50070:50070 --name=hadoop_292_docker --hostname=master-node hadoop_292`

`docker exec -it hadoop_292_docker /bin/bash`

# Inside of docker container

`hdfs namenode -format`

`start-dfs.sh`

`start-yarn.sh`

`hdfs dfs -mkdir -p /user/root`


