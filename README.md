# hadoop_285_docker

Docker for standalone and pseudo-distributed mode

# Build and run Hadoop Docker

`docker build -t hadoop_285 .`

`docker run -t -i -p 50070:50070 --name=hadoop_285_docker --hostname=master-node hadoop_285`

# Inside of docker container

`hdfs namenode -format`

`start-dfs.sh`

`start-yarn.sh`

`hdfs dfs -mkdir -p /user/root`


