1.Hive 접속하기
----------------------------------------------------------------------------------------------------------------------------
<pre><code>[root@sandbox-hdp practice_01]# beeline 
beeline> !connect jdbc:hive2://localhost:10000/default
Connecting to jdbc:hive2://localhost:10000/default
Enter username for jdbc:hive2://localhost:10000/default: hive
Enter password for jdbc:hive2://localhost:10000/default: hive
Connected to: Apache Hive (version 1.2.1000.2.6.4.0-91)
Driver: Hive JDBC (version 1.2.1000.2.6.4.0-91)
Transaction isolation: TRANSACTION_REPEATABLE_READ
0: jdbc:hive2://localhost:10000/default>
</code></pre>

<pre><code>beeline -u jdbc:hive2://localhost:10000/default -n hive -p hive</code></pre>

2.Hive 테이블 생성하기
----------------------------------------------------------------------------------------------------------------------------

<pre><code>CREATE DATABASE practice;</code></pre> 
<pre><code>CREATE TABLE practice.u_data (
  userid INT,
  movieid INT,
  rating INT,
  unixtime STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;
</code></pre>
<pre><code>use practice;
show tables;
show create table u_data;
</code></pre>

3.데이터 파일을 HDFS 로 복사 
----------------------------------------------------------------------------------------------------------------------------
<pre><code>[root@sandbox-hdp practice_01]# cd stage-data
[root@sandbox-hdp practice_01]# hadoop fs -mkdir /stage-data
[root@sandbox-hdp practice_01]# hadoop fs -put -f ml-100k /stage-data/.
[root@sandbox-hdp practice_01]# sudo -u hdfs hadoop fs -chown -R hive /stage-data/ml-100k
</code></pre>

4.Workflow File(workflow.xml) 
----------------------------------------------------------------------------------------------------------------------------

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workflow-app name="practice_01" xmlns="uri:oozie:workflow:0.5" xmlns:sla="uri:oozie:sla:0.2">
   <global/>
   <start to="hive_action_1"/>
   <kill name="Kill">
      <message>Action Failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
   </kill>
   <action name="hive_action_1">
       <hive2 xmlns="uri:oozie:hive2-action:0.2">
           <job-tracker>${jobTracker}</job-tracker>
           <name-node>${nameNode}</name-node>
           <prepare/>
           <configuration>
              <property>
                  <name>mapred.job.queue.name</name>
                  <value>${queueName}</value>
              </property>
           </configuration>
           <jdbc-url>jdbc:hive2://localhost:10000/practice</jdbc-url>
           <password>hive</password>
           <script>lib/load_datafile.hql</script>
       </hive2>
       <ok to="end"/>
       <error to="Kill"/>
    </action>
   <end name="end"/>
</workflow-app>
```


5.Library File(lib/load_datafile.hql) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>LOAD DATA INPATH '/stage-data/ml-100k/u.data' INTO TABLE practice.u_data;
</code></pre>

6.Job Propreties File(job.properties) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>user.name=mapred
oozie.use.system.libpath=true
oozie.wf.application.path=${nameNode}/user/oozie/workflow/practice_01
queueName=default
nameNode=hdfs://sandbox-hdp.hortonworks.com:8020
oozie.libpath=
jobTracker=sandbox-hdp.hortonworks.com\:8032
</code></pre>


7.oozie job 실행
----------------------------------------------------------------------------------------------------------------------------

1. workflow 경로를 HDFS 로 복사
<pre><code>[root@sandbox-hdp practice_01]# hadoop fs -put -f practice_01 /user/oozie/workflow/.
</code></pre>

2. oozie job run CLI command 실행
<pre><code>[root@sandbox-hdp practice_01]# oozie job -config job.properties -run
</code></pre>
