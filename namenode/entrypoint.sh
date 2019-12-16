#! /bin/bash

function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry="<property><name>$name</name><value>${value}</value></property>"
  local escapedEntry=$(echo $entry | sed 's/\//\\\//g')
  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path
}

echo "Configuring.............."
cd /opt/hadoop-2.7.1
pwd
# HDFS
addProperty /etc/hadoop/hdfs-site.xml dfs.namenode.name.dir file:///hadoop/dfs/name
addProperty /etc/hadoop/hdfs-site.xml dfs.permissions.enabled false
addProperty /etc/hadoop/hdfs-site.xml dfs.webhdfs.enabled true
addProperty /etc/hadoop/hdfs-site.xml dfs.namenode.rpc-bind-host 0.0.0.0
addProperty /etc/hadoop/hdfs-site.xml dfs.namenode.servicerpc-bind-host 0.0.0.0
addProperty /etc/hadoop/hdfs-site.xml dfs.namenode.http-bind-host 0.0.0.0
addProperty /etc/hadoop/hdfs-site.xml dfs.namenode.https-bind-host 0.0.0.0
addProperty /etc/hadoop/hdfs-site.xml dfs.client.use.datanode.hostname true
addProperty /etc/hadoop/hdfs-site.xml dfs.datanode.use.datanode.hostname true
addProperty /etc/hadoop/hdfs-site.xml dfs.replication 2


# YARN
addProperty /etc/hadoop/yarn-site.xml yarn.resourcemanager.fs.state-store.uri /rmstate
addProperty /etc/hadoop/yarn-site.xml yarn.resourcemanager.recovery.enabled true
addProperty /etc/hadoop/yarn-site.xml yarn.resourcemanager.store.class org.apache.hadoop.yarn.server.resourcemanager.recovery.FileSystemRMStateStore
addProperty /etc/hadoop/yarn-site.xml yarn.resourcemanager.system-metrics-publisher.enabled true
addProperty /etc/hadoop/yarn-site.xml yarn.resourcemanager.resource-tracker.address resourcemanager:8031
addProperty /etc/hadoop/yarn-site.xml yarn.resourcemanager.hostname namenode
addProperty /etc/hadoop/yarn-site.xml yarn.resourcemanager.scheduler.address resourcemanager:8030
addProperty /etc/hadoop/yarn-site.xml yarn.resourcemanager.address resourcemanager:8032
addProperty /etc/hadoop/yarn-site.xml yarn.resourcemanager.bind-host 0.0.0.0

addProperty /etc/hadoop/yarn-site.xml yarn.timeline-service.generic-application-history.enabled true
addProperty /etc/hadoop/yarn-site.xml yarn.timeline-service.enabled true
addProperty /etc/hadoop/yarn-site.xml yarn.timeline-service.hostname historyserver
addProperty /etc/hadoop/yarn-site.xml yarn.timeline-service.bind-host 0.0.0.0

addProperty /etc/hadoop/yarn-site.xml yarn.log-aggregation-enable true
addProperty /etc/hadoop/yarn-site.xml yarn.log.server.url http://historyserver:8188/applicationhistory/logs/

addProperty /etc/hadoop/yarn-site.xml yarn.nodemanager.remote-app-log-dir /app-logs
addProperty /etc/hadoop/yarn-site.xml yarn.nodemanager.bind-host 0.0.0.0

addProperty /etc/hadoop/yarn-site.xml yarn.nodemanager.aux-services mapreduce_shuffle
addProperty /etc/hadoop/yarn-site.xml yarn.nodemanager.aux-services.mapreduce_shuffle.class org.apache.hadoop.mapred.ShuffleHandler

cp /opt/hadoop-2.7.1/etc/hadoop/mapred-site.xml.template /opt/hadoop-2.7.1/etc/hadoop/mapred-site.xml
# MAPRED
addProperty /etc/hadoop/mapred-site.xml yarn.nodemanager.bind-host 0.0.0.0
addProperty /etc/hadoop/mapred-site.xml mapreduce.framework.name yarn
addProperty /etc/hadoop/mapred-site.xml mapreduce.jobhistory.address resourcemanager:50020
addProperty /etc/hadoop/mapred-site.xml mapreduce.jobhistory.webapp.address resourcemanager:19888
addProperty /etc/hadoop/mapred-site.xml mapreduce.jobhistory.intermediate-done-dir /mr-history/tmp
addProperty /etc/hadoop/mapred-site.xml mapreduce.jobhistory.done-dir /mr-history/done
addProperty /etc/hadoop/mapred-site.xml mapreduce.jobhistory.bind-host 0.0.0.0
addProperty /etc/hadoop/mapred-site.xml mapreduce.jobhistory.hostname resourcemanager

# CORE
addProperty /etc/hadoop/core-site.xml hadoop.proxyuser.hue.hosts*
addProperty /etc/hadoop/core-site.xml fs.defaultFS hdfs://namenode:8020
addProperty /etc/hadoop/core-site.xml hadoop.proxyuser.hue.groups *
addProperty /etc/hadoop/core-site.xml hadoop.http.staticuser.user root

# yarn-env.sh
sed -i '/# export JAVA_HOME=\/home\/y\/libexec\/jdk1.6.0/aexport JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64\/' /etc/hadoop/yarn-env.sh
# hadoop-env.sh
sed -i '/export JAVA_HOME=${JAVA_HOME}/aexport JAVA_HOME=\/usr\/lib\/jvm\/java-8-openjdk-amd64\/' /etc/hadoop/hadoop-env.sh

# hadoop slaves
sed -i '/localhost/adatanode1\ndatanode2\ndatanode3' /etc/hadoop/slaves
sed -i '1d' /etc/hadoop/slaves

# ssh
cd /
echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# spark
cd /opt/spark-2.4.4-bin-hadoop2.7
##slaves
cp conf/slaves.template conf/slaves
sed -i '/localhost/adatanode1\ndatanode2\ndatanode3' conf/slaves
sed -i '19d' conf/slaves
##spark-env.sh
cp conf/spark-env.sh.template conf/spark-env.sh
echo 'export SPARK_HOME=/opt/spark-2.4.4-bin-hadoop2.7' >> conf/spark-env.sh
echo 'export SCALA_HOME=/opt/scala-2.11.12' >> conf/spark-env.sh
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/' >> conf/spark-env.sh
echo 'export HADOOP_HOME=/opt/hadoop-2.7.1' >> conf/spark-env.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SCALA_HOME/bin' >> conf/spark-env.sh
echo 'export HADOOP_CONF_DIR=/etc/hadoop' >> conf/spark-env.sh
echo 'export SPARK_MASTER_IP=namenode' >> conf/spark-env.sh
echo 'SPARK_LOCAL_DIRS=/opt/spark-2.4.4-bin-hadoop2.7' >> conf/spark-env.sh
echo 'SPARK_DRIVER_MEMORY=1G' >> conf/spark-env.sh
echo 'SPARK_LOCAL_DIRS=/opt/spark-2.4.4-bin-hadoop2.7/locale' >> conf/spark-env.sh
echo 'export SPARK_LIBARY_PATH=.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$HADOOP_HOME/lib/native' >> conf/spark-env.sh


