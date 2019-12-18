# >>>>当前Cluster状况<<<<<

## 1. cluster各节点

**namenode**: 10.101.100.1(weave ip:10.32.0.1)

**datanode1(CPU)**: 10.101.100.2(weave ip:10.35.0.1)
> 登录server 10.101.100.2： `ssh support@10.101.100.2`
>
> 进入container datanode1：`sudo docker exec -it datanode1 bash`

**datanode2(CPU)**: 10.101.100.5(weave ip:10.36.0.1)
> 登录server 10.101.100.5： `ssh support@10.101.100.5`
>
> 进入container datanode2：`sudo docker exec -it datanode2 bash`

**datanode3(GPU)**: 未知(weave ip:10.37.0.1)

> 登录server 10.101.100.1: `ssh support@10.101.100.1`
>
> 进入container datanode3:
>
```
   cd login_datanode
   sh login_datanode3.sh
```



## 2. cluster监测

> **hadoop集群状况**: 10.101.100.1:9999
>
> **yarn界面**:       10.101.100.1:8088
>
> **spark集群状况**:  10.101.100.1:8080



# >>>>>Cluster启动与停止<<<<<

## 1. 启动/停止hadoop集群

在namenode内执行：
```
cd /opt/hadoop-2.7.1
./sbin/start-all.sh #启动
./sbin/stop-all.sh #停止
./sbin/mr-jobhistory-daemon.sh start historyserver #启动historyserver
```

## 2. 启动/停止spark集群

在namenode内执行：
```
cd /opt/spark-2.4.4-bin-hadoop2.7
./sbin/start-all.sh #启动
./sbin/stop-all.sh #停止
```


# >>>>>增加新的datanode<<<<<

## 1. datanode with CPU

>*例如：增加datanode4*

* **step1:  生成datanode4的基础镜像**

复制datanode1文件夹，重命名为datanode4(下列操作都在此文件夹下进行)，在当前文件夹下执行 docker build --no-cache -t {image_name} .
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
    - "8888":"8888"
    volumes:
    + - hadoop_datanode4:/hadoop/dfs/data
      - ./entrypoint.sh:/entrypoint.sh
      - cluster-nas-env:/mnt
    env_file:
      - ./hadoop.env
    environment:
      - LANG=C.UTF-8
      - TZ=Asia/Shanghai
      
volumes:
+ hadoop_datanode4:
  cluster-nas-env:
     driver_opts:
       type: "cifs"
       device: //10.70.22.42/data_team
       o: "username=data,password=tclbigdata19"
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

* **step8:  修改相关配置**

    1. 进入namenode的container，修改文件/opt/hadoop-2.7.1/etc/hadoop/slaves, /opt/spark-2.4.4-bin-hadoop2.7/conf/slaves
    分别追加datanode4。
    
    注：此操作后需要commit当前image保存修改。
    
    2. 修改其他节点的docker-compose.yml,在extra_hosts下，追加 - "datanode4:10.38.0.1"。


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

## 2. datanode with GPU

参考datanode3文件夹内容及上述步骤。
