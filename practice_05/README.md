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
```sql
CREATE DATABASE weblogs;

CREATE EXTERNAL TABLE IF NOT EXISTS weblogs.access_log(
  remote_host STRING,
  remote_logname STRING,
  remote_user STRING,
  request_time STRING,
  first_line STRING,
  http_status STRING,
  bytes STRING,
  referer STRING,
  agent STRING
)
PARTITIONED BY (etl_ymd string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
  "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*) ([^ ]*) ([^ ]*)",
  "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s"
);

CREATE TABLE weblogs.access_log_orc(
   `remote_host` string,
   `remote_logname` string,
   `remote_user` string,
   `request_time` timestamp,
   `first_line` string,
   `http_status` string,
   `bytes` string,
   `referer` string,
   `agent` string)
 PARTITIONED BY ( ymd string )
 STORED AS ORC;    
```

3.Workflow File(workflow.xml) 
----------------------------------------------------------------------------------------------------------------------------
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workflow-app name="practice_05" xmlns="uri:oozie:workflow:0.5" xmlns:sla="uri:oozie:sla:0.2">
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
           <script>lib/load_logfile.hql</script>
           <param>ETL_YMD=${YMD}</param>
       </hive2>
       <ok to="hive_action_2"/>
       <error to="Kill"/>
   </action>
   <action name="hive_action_2">
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
           <jdbc-url>jdbc:hive2://localhost:10000/default</jdbc-url>
           <password>hive</password>
           <script>lib/copy_to_orc.hql</script>
           <param>YMD=${YMD}</param>
       </hive2>
       <ok to="end"/>
       <error to="Kill"/>
    </action>
   <end name="end"/>
</workflow-app>
```

4.Library File(lib/load_logfile.hql) 생성
----------------------------------------------------------------------------------------------------------------------------
```sql
--LOAD DATA INPATH '/stage-data/weblog/access/${ETL_YMD}/*.LOG' INTO TABLE weblogs.access_log 
--       PARTITION(etl_ymd=${ETL_YMD});
ALTER TABLE weblogs.access_log ADD IF NOT EXISTS PARTITION (etl_ymd='${ETL_YMD}') LOCATION  
         '/stage-data/weblogs/access/${ETL_YMD}';
```

5.Library File(lib/copy_to_orc.hql) 생성
----------------------------------------------------------------------------------------------------------------------------
```sql
ALTER TABLE weblogs.access_log_orc DROP IF EXISTS PARTITION (ymd=${YMD});

INSERT OVERWRITE TABLE weblogs.access_log_orc PARTITION (ymd=${YMD})
SELECT remote_host, remote_logname, remote_user,
       cast(from_unixtime(UNIX_TIMESTAMP(request_time,'[dd/MMM/yyyy:HH:mm:ss Z]')) as timestamp) as request_time,
       first_line, http_status, bytes, referer, agent
FROM weblogs.access_log
WHERE etl_ymd=${YMD};
```

6.Job Propreties File(workflow-job.properties) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>user.name=mapred
oozie.use.system.libpath=true
oozie.wf.application.path=${nameNode}/user/oozie/workflow/practice_05
queueName=default
nameNode=hdfs://sandbox-hdp.hortonworks.com:8020
oozie.libpath=/user/oozie/share/lib/lib_20180201102929/sqoop
jobTracker=sandbox-hdp.hortonworks.com\:8032
YMD=20180401
</code></pre>


7.Coordinator File(coordinator.xml) 생성
----------------------------------------------------------------------------------------------------------------------------
```xml
<coordinator-app xmlns:sla="uri:oozie:sla:0.2" xmlns="uri:oozie:coordinator:0.4" name="weblog_coordinator" 
                 frequency="10 0 * * *" start="2018-04-02T00:00+0900" end="2020-12-31T02:00+0900" 
                 timezone="Asia/Seoul">
    <controls>
        <timeout>86400</timeout>
    </controls>
    <datasets>
        <dataset name="data" frequency="1440" initial-instance="2018-04-01T00:00+0900"
                 timezone="Asia/Seoul">
            <uri-template>${nameNode}/stage-data/weblogs/access/${YEAR}${MONTH}${DAY}</uri-template>
            <done-flag></done-flag>
        </dataset>
    </datasets>
    <input-events>
        <data-in name="input" dataset="data">
           <instance>${coord:current(0)}</instance>
        </data-in>
    </input-events>
    <action>
        <workflow>
            <app-path>/user/oozie/workflow/practice_05/workflow.xml</app-path>
            <configuration>
                <property>
                    <name>YMD</name>
                    <value>${coord:formatTime(coord:nominalTime(),'yyyyMMdd')}</value>
                </property>
            </configuration>
        </workflow>
    </action>    
</coordinator-app>
```

8.Coordinator Job Propreties File(coord-job.properties) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>user.name=mapred
oozie.use.system.libpath=true
oozie.coord.application.path=${nameNode}/user/oozie/workflow/practice_05/coordinator.xml
queueName=default
nameNode=hdfs://sandbox-hdp.hortonworks.com:8020
oozie.libpath=
jobTracker=sandbox-hdp.hortonworks.com\:8032
</code></pre>


