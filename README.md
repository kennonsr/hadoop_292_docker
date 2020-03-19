# hadoop_285_docker

Docker for standalone and pseudo-distributed mode

# Build and run Hadoop Docker

`docker build -t hadoop_285 .`

`docker run -t -i -p 50070:50070 --name=master-node --hostname=master-node hadoop_285`

# Inside of docker container

`chmod 777 -R /hadoop/data/01/*`

`hdfs namenode -format`

`hdfs dfs -mkdir -p /user/root`

`start-all.sh`
