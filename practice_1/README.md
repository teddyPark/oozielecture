1. Hive 테이블 생성하기
----------------------------------------------------------------------------------------------------------------------------
<pre><code>
[root@sandbox-hdp lecture_01]# beeline 
beeline> !connect jdbc:hive2://localhost:10000/default  (id : hive / pwd : hive)

CREATE DATABASE lecture; 
CREATE EXTERNAL TABLE 'lecture.u_data' (
  userid INT,
  movieid INT,
  rating INT,
  unixtime STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION 'hdfs://sandbox-hdp.hortonworks.com:8020/user/hive/warehouse/lecture.db/u_data';
</code></pre>

2. 파일 소유자 변경 
----------------------------------------------------------------------------------------------------------------------------
<pre><code>[root@sandbox-hdp lecture_01]# sudo -u hdfs hadoop fs -chown -R hive /stage-data/ml-100k
</code></pre>

Workflow File : workflow.xml
----------------------------------------------------------------------------------------------------------------------------

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workflow-app name="lecture_01" xmlns="uri:oozie:workflow:0.5" xmlns:sla="uri:oozie:sla:0.2">
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
           <jdbc-url>jdbc:hive2://localhost:10000/lecture</jdbc-url>
           <password>hive</password>
           <script>lib/load_datafile.hql</script>
       </hive2>
       <ok to="end"/>
       <error to="Kill"/>
    </action>
   <end name="end"/>
</workflow-app>
```



Library File : lib/load_datafile.hql
----------------------------------------------------------------------------------------------------------------------------
<pre><code>LOAD DATA INPATH '/stage-data/ml-100k/u.data' INTO TABLE lecture.u_data;
</code></pre>

File : job.properties
----------------------------------------------------------------------------------------------------------------------------
<pre><code>user.name=mapred
TODAY_YMD=20180507
oozie.use.system.libpath=true
oozie.wf.application.path=${nameNode}/user/oozie/workflow/lecture_01
queueName=default
nameNode=hdfs://sandbox-hdp.hortonworks.com:8020
oozie.libpath=
jobTracker=sandbox-hdp.hortonworks.com\:8032
</code></pre>


oozie job 실행 방법
----------------------------------------------------------------------------------------------------------------------------

1. workflow 경로를 HDFS 로 복사
<pre><code>hadoop fs -put (-f) lecture_01 /user/oozie/workflow/.
</code></pre>

2. job.properties 파일이 있는 경로로 이동.
<pre><code>cd lecture_01
</code></pre>

3. oozie CLI command 실행
<pre><code>oozie job -config job.properties -run
</code></pre>
