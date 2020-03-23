#Build a pseudo distributed and standalone Hadoop   version 2.9.2

FROM ubuntu:18.04

MAINTAINER Kennon <kennon.rodrigues@linkit.nl>
#LABEL version="hadoop_285_pseudo_distributed"
LABEL version="hadoop_292_pseudo"

USER root

# Install Python.

#RUN \
#  apt-get update && \
#  apt-get install -y python python-dev python-pip python-virtualenv && \
#  rm -rf /var/lib/apt/lists/*

# Install system tools

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y vim sudo curl git htop man unzip nano wget mlocate openssl net-tools sudo openssh-server ssh && \
  rm -rf /var/lib/apt/lists/*

#ARG DEBIAN_FRONTEND=noninteractive
RUN \
   apt-get update && \
   DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
RUN echo "Europe/Amsterdam" >  /etc/timezone
RUN rm -rf /var/lib/apt/lists/*

# Install Java - OpenJDK8

RUN \
  apt-get update && \
  apt-get install -y  openjdk-8-jdk && \
  rm -rf /var/lib/apt/lists/* && \
  Javadir=$(dirname $(dirname $(readlink -f $(which javac)))) && \
  java -version

# Define commonly used JAVA_HOME variable

ENV JAVA_HOME $Javadir

# SSH PASSWORDLESS
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

# Add Hadoop 2.9.2  to source.lists.d
RUN useradd -rm hadoop
RUN useradd -rm hdfs
RUN cd ~/
RUN wget https://downloads.apache.org/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz ; tar -zxf hadoop-2.9.2.tar.gz -C /usr/local/ ; rm hadoop-2.9.2.tar.gz
RUN cd /usr/local && ln -s ./hadoop-2.9.2 hadoop
RUN systemctl enable ssh


#HADOOP ENV

ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\n\
export HADOOP_PREFIX=/usr/local/hadoop \n\
export HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# PSEUDO DISTRIBUTED MODE CONF
# # pseudo distributed
ADD hadoop_config/core-site.xml $HADOOP_PREFIX/etc/hadoop/core-site.xml
ADD hadoop_config/hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
ADD hadoop_config/mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD hadoop_config/yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml

#ADD hadoop_config/slaves $HADOOP_PREFIX/etc/hadoop/slaves
#
ADD hadoop_config/ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config
#
ADD hadoop_config/bootstrap.sh /usr/local/bootstrap.sh
RUN chown root:root /usr/local/bootstrap.sh
RUN chmod 700 /usr/local/bootstrap.sh
#

#ADD USER HADOOP DEV hddev
RUN useradd -rm -d /home/hddev -s /bin/bash -g root -G sudo -u 1054 hddev
#USER hddev
#WORKDIR /home/ubuntu

#custom TERM
RUN  echo 'PS1="\[$(tput bold)\]\[\033[38;5;193m\]>>>\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;192m\]\u\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]@\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;117m\]\H\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]:[\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;223m\]\w\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]]:[\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;192m\]\T\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]]\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]{\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;208m\]\$?\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]}\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;193m\]>>>\[$(tput sgr0)\]\[\033[38;5;15m\]\n\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;9m\]\\$\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"' >> /etc/bash.bashrc
RUN  echo 'PS1="\[$(tput bold)\]\[\033[38;5;193m\]>>>\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;192m\]\u\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]@\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;117m\]\H\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]:[\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;223m\]\w\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]]:[\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;192m\]\T\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]]\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]{\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;208m\]\$?\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;253m\]}\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;193m\]>>>\[$(tput sgr0)\]\[\033[38;5;15m\]\n\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;9m\]\\$\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"' >> ~/.bashrc

#ENTRYPOINT
#ENTRYPOINT ["/bin/bash"]

ENV BOOTSTRAP /usr/local/bootstrap.sh
RUN service ssh start
RUN mkdir -p /hadoop/data/01
RUN chmod 777 -R /hadoop/data/01*
#
CMD ["/usr/local/bootstrap.sh", "-d"]

# # Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# # Mapred ports
EXPOSE 10020 19888
# #Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
# SSH
EXPOSE 22
