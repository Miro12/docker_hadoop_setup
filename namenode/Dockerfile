FROM ubuntu:16.04

MAINTAINER Li Jiayin <lijiayin12@yahoo.com>

RUN apt-get update && apt-get install -y \
    net-tools \
    netcat \
    gnupg \
    openjdk-8-jdk \
    wget \
    curl \
    vim \
    ssh \
    openssh-server \ 
    && rm -rf /var/lib/apt/lists/*

RUN /etc/init.d/ssh start \
    && ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
ENV HADOOP_VERSION 2.7.1

RUN cd /opt \
    && wget https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
    && tar -zxvf hadoop-$HADOOP_VERSION.tar.gz

RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
RUN mkdir /opt/hadoop-$HADOOP_VERSION/logs
RUN mkdir /hadoop-data

ENV HADOOP_PREFIX=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root
ENV PATH $HADOOP_PREFIX/bin/:$PATH

###############scala###################
ENV SCALA_VERSION 2.11.12
RUN cd /opt \
    && wget https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz \
    && tar -zxvf scala-$SCALA_VERSION.tgz
ENV SCALA_HOME=/opt/scala-$SCALA_VERSION
ENV PATH $SCALA_HOME/bin/:$PATH

##############spark####################
ENV SPARK_VERSION 2.4.4
RUN cd /opt \
    && wget http://mirror-hk.koddos.net/apache/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz \
    && tar -zxvf spark-$SPARK_VERSION-bin-hadoop2.7.tgz 
ENV SPARK_HOME=/opt/spark-$SPARK_VERSION-bin-hadoop2.7
ENV PATH $SPARK_HOME/bin/:$PATH
ENV LD_LIBRARY_PATH=$HADOOP_PREFIX/lib/native
ENV PYSPARK_PYTHON=python3.5


