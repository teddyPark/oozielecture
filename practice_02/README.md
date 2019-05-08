> The data comes originally from RITA where it is described in detail. You can download the data there, or from the bzipped csv files listed below. These files have derivable variables removed, are packaged in yearly chunks and have been more heavily compressed than the originals.

> ref : http://stat-computing.org/dataexpo/2009/the-data.html

# Data description
<pre>
  Name	          Description
1	Year	          1987-2008
2	Month	          1-12
3	DayofMonth	    1-31
4	DayOfWeek	      1 (Monday) - 7 (Sunday)
5	DepTime	        actual departure time (local, hhmm)
6	CRSDepTime	    scheduled departure time (local, hhmm)
7	ArrTime	        actual arrival time (local, hhmm)
8	CRSArrTime	    scheduled arrival time (local, hhmm)
9	UniqueCarrier	  unique carrier code
10	FlightNum	      flight number
11	TailNum	        plane tail number
12	ActualElapsedTime	  in minutes
13	CRSElapsedTime	  in minutes
14	AirTime	      in minutes
15	ArrDelay	    arrival delay, in minutes
16	DepDelay	    departure delay, in minutes
17	Origin	      origin IATA airport code
18	Dest	        destination IATA airport code
19	Distance	    in miles
20	TaxiIn	      taxi in time, in minutes
21	TaxiOut	      taxi out time in minutes
22	Cancelled	    was the flight cancelled?
23	CancellationCode	  reason for cancellation (A = carrier, B = weather, C = NAS, D = security)
24	Diverted	    1 = yes, 0 = no
25	CarrierDelay	    in minutes
26	WeatherDelay	    in minutes
27	NASDelay	    in minutes
28	SecurityDelay	    in minutes
29	LateAircraftDelay	    in minutes
</pre>

1.File 내용 확인하기
------------------------------------------
<pre><code>[root@sandbox-hdp stage-data]# cd RITA_Data
[root@sandbox-hdp RITA_Data]# head 2000/2000.csv
</code></pre>

2.HDFS 로 업로드 하기
-----------------------------------------
<pre><code>[root@sandbox-hdp stage-data]# hadoop fs -put RITA_Data /stage-data/.
</code></pre>

3.file 확인하기
-------------------------------------------
<pre><code>[root@sandbox-hdp stage-data]# hadoop fs -ls -R /stage-data/RITA_Data
</code></pre>

4.Hive 테이블 생성하기
----------------------------------------------------------------------------------------------------------
<pre><code>[root@sandbox-hdp practice_02]# beeline -u jdbc:hive2://sandbox-hdp.hortonworks.com:10000/practice -n hive -p hive
</code></pre>

<pre><code>CREATE EXTERNAL TABLE practice.flight_data_tmp (
   `year` int,
   `month` int,
   `day` int,       
   `day_of_week` int,
   `dep_time` int,
   `crs_dep_time` int,
   `arr_time` int,
   `crs_arr_time` int,
   `unique_carrier` string,
   `flight_num` int,
   `tail_num` string,
   `actual_elapsed_time` int,
   `crs_elapsed_time` int,
   `air_time` int,
   `arr_delay` int,
   `dep_delay` int,
   `origin` string,
   `dest` string,
   `distance` int,
   `taxi_in` int,
   `taxi_out` int,
   `cancelled` int,
   `cancellation_code` string,
   `diverted` int,
   `carrier_delay` string,
   `weather_delay` string,
   `nas_delay` string,
   `security_delay` string,
   `late_aircraft_delay` string)
 PARTITIONED BY (`etl_year` string)
 ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
 STORED AS INPUTFORMAT
   'org.apache.hadoop.mapred.TextInputFormat'
 OUTPUTFORMAT
   'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
 LOCATION
   'hdfs://sandbox-hdp.hortonworks.com:8020/user/hive/warehouse/practice.db/flight_data_tmp';
</code></pre>

<pre><code>CREATE EXTERNAL TABLE practice.flight_data_orc (
   `month` int,
   `day` int,       
   `day_of_week` int,
   `dep_time` int,
   `crs_dep_time` int,
   `arr_time` int,
   `crs_arr_time` int,
   `unique_carrier` string,
   `flight_num` int,
   `tail_num` string,
   `actual_elapsed_time` int,
   `crs_elapsed_time` int,
   `air_time` int,
   `arr_delay` int,
   `dep_delay` int,
   `origin` string,
   `dest` string,
   `distance` int,
   `taxi_in` int,
   `taxi_out` int,
   `cancelled` int,
   `cancellation_code` string,
   `diverted` int,
   `carrier_delay` string,
   `weather_delay` string,
   `nas_delay` string,
   `security_delay` string,
   `late_aircraft_delay` string)
 PARTITIONED BY (`year` string)
 STORED AS ORC
 LOCATION
   'hdfs://sandbox-hdp.hortonworks.com:8020/user/hive/warehouse/practice.db/flight_data_orc';
</code></pre>

5.Workflow File(workflow.xml) 
----------------------------------------------------------------------------------------------------------------------------
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workflow-app name="practice_02" xmlns="uri:oozie:workflow:0.5" xmlns:sla="uri:oozie:sla:0.2">
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
           <script>lib/load_csvfile.hql</script>
           <param>ETL_YEAR=${YEAR}</param>
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
           <param>YEAR=${YEAR}</param>
       </hive2>
       <ok to="end"/>
       <error to="Kill"/>
    </action>
   <end name="end"/>
</workflow-app>
```

6.Library File(lib/load_csvfile.hql) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>LOAD DATA INPATH '/stage-data/RITA_Data/${ETL_YEAR}/*.csv' INTO TABLE practice.flight_data_tmp PARTITION(etl_year=${ETL_YEAR});
</code></pre>

7.Library File(lib/copy_to_orc.hql) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>INSERT OVERWRITE TABLE practice.flight_data_orc 
PARTITION (year='${YEAR}')
SELECT
   month,
   day,
   day_of_week,
   dep_time,
   crs_dep_time,
   arr_time,
   crs_arr_time,
   unique_carrier,
   flight_num,
   tail_num,
   actual_elapsed_time,
   crs_elapsed_time,
   air_time,
   arr_delay,
   dep_delay,
   origin,
   dest,
   distance,
   taxi_in,
   taxi_out,
   cancelled, 
   cancellation_code, 
   diverted,
   carrier_delay,
   weather_delay,
   nas_delay,
   security_delay,
   late_aircraft_delay
FROM practice.flight_data_tmp WHERE etl_year = '${YEAR}';
</code></pre>

8.Job Propreties File(job.properties) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>user.name=mapred
oozie.use.system.libpath=true
oozie.wf.application.path=${nameNode}/user/oozie/workflow/practice_02
queueName=default
nameNode=hdfs://sandbox-hdp.hortonworks.com:8020
oozie.libpath=
jobTracker=sandbox-hdp.hortonworks.com\:8032
YEAR=2000
</code></pre>

9.oozie job 실행
----------------------------------------------------------------------------------------------------------------------------
1. workflow 경로를 HDFS 로 복사
<pre><code>[root@sandbox-hdp practice_02]# hadoop fs -put -f practice_02 /user/oozie/workflow/.
</code></pre>

2. oozie CLI command 실행
<pre><code>[root@sandbox-hdp practice_02]# oozie job -config job.properties -run
</code></pre>

3. oozie workflow job 확인
<pre><code>[root@sandbox-hdp practice_02]# oozie job -info {job_id}
</code></pre>

4. hive_action_2 오류 확인하기
<pre><code>[root@sandbox-hdp practice_02]# oozie job -info {job_id}@hive_action_2
</code></pre>

5. STDOUT/STDERR 확인하기
http://sandbox-hdp.hortonworks.com:8088/proxy/{yarn application id}/

6. hql 파일 수정 후 HDFS 에 업로드하기
 * copy_to_orc.hql 파일의 ${ETL_YEAR} 를 ${YEAR}로 변경
<pre><code>[root@sandbox-hdp practice_02]# hadoop fs -put -f lib /user/oozie/workflow/practice_02
</code></pre>

7. oozie job rerun
<pre><code>[root@sandbox-hdp practice_02]# oozie job -rerun {job id} -Doozie.wf.rerun.failnodes=true
</code></pre>

8. stage-data file 확인
<pre><code>[root@sandbox-hdp practice_02]# hadoop fs -ls -R /stage-data/RITA_Data/
</code></pre>

9. flight_data_tmp table 의 external location 확인
<pre><code>[root@sandbox-hdp practice_02]# hadoop fs -ls -R /user/hive/warehouse/practice.db/flight_data_tmp
</code></pre>

10. hive 테이블 확인
<pre><code>[root@sandbox-hdp practice_02]# beeline -u jdbc:hive2://sandbox-hdp.hortonworks.com:10000/practice -n hive -p hive
0: jdbc:hive2://sandbox-hdp.hortonworks.com:1> SELECT count(*) FROM practice.flight_data_tmp WHERE etl_year=2000;
0: jdbc:hive2://sandbox-hdp.hortonworks.com:1> SELECT count(*) FROM practice.flight_data_orc WHERE year=2000;
</code></pre>
