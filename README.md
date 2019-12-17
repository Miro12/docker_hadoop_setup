# docker_hadoop_setup
 ## 1. add a Datanode

### 1.1 datanode with CPU

>*例如：增加datanode4*

* **step1:  生成datanode4的基础镜像**

在Dockerfile所在文件夹下执行 docker build --no-cache -t {image_name} .
```
docker build --no-cache -t  datanode4:base-spark2.4.4-hadoop2.7.1-java . 
```
* **step2:  编辑docker-compose.yml**

```diff
version: "2"
services:
+ datanode4:
+   image: datanode4: base-spark2.4.4-hadoop2.7.1-java8
+   container_name: datanode4
+   hostname: datanode4
    extra_hosts:
      - "namenode:10.32.0.1"
      - "datanode1:10.35.0.1"
      - "datanode2:10.36.0.1"
      - "resourcemanager:10.32.0.1"
      - "historyserver:10.32.0.1"
      - "datanode3:10.37.0.1"
+     - "datanode4:10.38.0.1"
+   entrypoint:  bash -c " ./entrypoint.sh && /etc/init.d/ssh start && tail -f /dev/null"
    tty: true
    ports:
    - "8081:8081"
    - "8042:8042"
    volumes:
+     - hadoop_datanode4:/hadoop/dfs/data
      - ./entrypoint.sh:/entrypoint.sh
    env_file:
      - ./hadoop.env
volumes:
+   hadoop_datanode4:
```

* **step3:  编辑weave_set.sh, 配置container的网络环境**

```
weave launch 10.101.100.1
weave attach 10.38.0.1/12 datanode4
```
    ！注：chmod +x weave_set.sh #赋予执行权限

* **step4:  启动container**

```
docker-compose up -d
./weave_set.sh
```

！补充weave相关
```
#安装weave
curl -L git.io/weave -o /usr/local/bin/weave  #下载
chmod a+x /usr/local/bin/weave  #赋予执行权限
#查看weave版本
weave version
```

* **step5:  进入container**

```
docker exec -it datanode4  bash
```

* **step6:  在datanode4内部设置ssh相关配置**

    把namenode的~/.ssh/id_rsa.pub 追加进datanode4的~/.ssh/authorized_keys 


* **step7: 退出container，commit当前container到最终的datanode4镜像**

```
docker commit {containerId} datanode4:cpu-spark2.4.4-hadoop2.7.1-java
```

* **step8:  修改namenode的相关配置**

    e.g. 修改/opt/hadoop-2.7.1/etc/hadoop/slaves, 追加datanode4


* **step9:  重复step2，修改docker-compose.yml部分语句**

```diff
- image: datanode4: base-spark2.4.4-hadoop2.7.1-java8  -->  
+ image: datanode4: cpu-spark2.4.4-hadoop2.7.1-java8
- entrypoint:  bash -c " ./entrypoint.sh && /etc/init.d/ssh start && tail -f /dev/null"  --> 
+ entrypoint:  bash -c " /etc/init.d/ssh start && tail -f /dev/null"
```

* **step10:  完成**

    启动datanode4，即step4
    进入datanode4，即step5
