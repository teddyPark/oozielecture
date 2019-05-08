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

CREATE EXTERNAL TABLE weblogs.access(
   `host` string,                                                                       
   `identity` string,                                                                   
   `userid` string,                                                                     
   `accesstime` string,                                                              
   `request` string,                                                                    
   `status` string,                                                                     
   `size` string,                                                                       
   `referer` string,                                                                    
   `agent` string)
 PARTITIONED BY ( etl_ymd string )
 ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ' '
 STORED AS INPUTFORMAT                                                                  
   'org.apache.hadoop.mapred.TextInputFormat'
 OUTPUTFORMAT                                                                           
   'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'                         
 LOCATION                                                                               
   'hdfs://sandbox-hdp.hortonworks.com:8020/stage-data/weblog/access';  
```

```sql
// new table schema
CREATE EXTERNAL TABLE IF NOT EXISTS raw_access_log(
  remote_host STRING,
  remote_logname STRING,
  remote_user STRING,
  request_time STRING,
  first_line STRING,
  http_status STRING,
  bytes STRING
)
PARTITIONED BY (site string, log_date string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.contrib.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
  "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)",
  "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s"
);

LOAD DATA INPATH "/tmp/hive/weblogs/metatron_app_access_log-${yyyymmdd}" OVERWRITE INTO TABLE metatron_weblog.raw_access_log 
   PARTITION (site='metatron.app',log_date='${yyyymmdd}');
   
CREATE TABLE `weblogs.access_orc`(
   `host` string,
   `identity` string,
   `userid` string,
   `accesstime` timestamp,
   `request` string,
   `status` string,
   `size` string,
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



   <end name="end"/>
</workflow-app>
```

4.Library File(lib/load_logfile.hql) 생성
----------------------------------------------------------------------------------------------------------------------------
```sql
--LOAD DATA INPATH '/stage-data/weblogs/access/${ETL_YMD}/*.LOG' INTO TABLE weblogs.access PARTITION(etl_ymd=${ETL_YMD});
ALTER TABLE access ADD IF NOT EXISTS PARTITION (etl_ymd='${ETL_YMD}') LOCATION '/stage-data/weblog/access/${ETL_YMD}';
```

5.Library File(lib/copy_to_orc.hql) 생성
----------------------------------------------------------------------------------------------------------------------------
```sql
ALTER TABLE weblogs.access_orc DROP IF EXISTS PARTITION (ymd=${YMD});

INSERT OVERWRITE TABLE weblogs.access_orc PARTITION (ymd=${YMD})
SELECT host, identity, userid,
         cast(from_unixtime(UNIX_TIMESTAMP(accesstime,'[dd/MMM/yyyy:HH:mm:ss Z]')) as timestamp) as accesstime,
         request, status, size, referer, agent
FROM weblogs.access
WHERE etl_ymd=${YMD};
```

6.Job Propreties File(job.properties) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>

</code></pre>


7.Coordinator File(coordinator.xml) 생성
----------------------------------------------------------------------------------------------------------------------------
```xml
<coordinator-app xmlns="uri:oozie:coordinator:0.4" name="weblog_coordinator" frequency=" " start=" " end=" " timezone=" ">


</coordinator-app>
```

8.Coordinator Job Propreties File(coordinator-job.properties) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>

</code></pre>

