1.mysql 에 sqoop user 추가 및 권한 설정
----------------------------------------------------------------------------------------------------------------------------
<pre><code>[root@sandbox-hdp ]# mysql -u root -p (password : hadoop)
mysql> grant all privileges on employees.* to 'sqoop'@'localhost' identified by 'hadoop';
mysql> flush privileges;
</code></pre>

2.beeline 으로 Hive 접속 후 Database 와 Table 만들기
----------------------------------------------------------------------------------------------------------------------------
<pre><code>CREATE DATABASE employees;

CREATE EXTERNAL TABLE employees.employees (
   emp_no int,
   birth_date date,
   first_name string,
   last_name string,
   gender string,
   hire_date date)
ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
STORED AS INPUTFORMAT
   'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
   'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
   'hdfs://sandbox-hdp.hortonworks.com:8020/stage-data/employees';
</code></pre>

3.Workflow File(workflow.xml) 
----------------------------------------------------------------------------------------------------------------------------
```xml
<workflow-app name="practice_03" xmlns="uri:oozie:workflow:0.5" xmlns:sla="uri:oozie:sla:0.2">
   <global/>
   <start to="sqoop_action_1"/>
   <kill name="Kill">
      <message>Action Failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
   </kill>
   <action name="sqoop_action_1">
       <sqoop xmlns="uri:oozie:sqoop-action:0.2">
           <job-tracker>${jobTracker}</job-tracker>
           <name-node>${nameNode}</name-node>
           <prepare/>
           <configuration>
              <property>
                  <name>mapred.job.queue.name</name>
                  <value>${queueName}</value>
              </property>
           </configuration>
           <command>import --connect jdbc:mysql://localhost:3306/employees --driver com.mysql.jdbc.Driver --username sqoop --password hadoop --table employees --target-dir /stage-data/employees --split-by 1 --delete-target-dir</command>
       </sqoop>
       <ok to="hive_action_1"/>
       <error to="Kill"/>
   </action>
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
           <script>lib/ctas_orc.hql</script>
       </hive2>
       <ok to="end"/>
       <error to="Kill"/>
    </action>
   <end name="end"/>
</workflow-app>
```

4.Library File(lib/ctas_orc.hql) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>DROP TABLE IF EXISTS employees.employees_orc;
CREATE TABLE employees.employees_orc STORED AS ORC AS SELECT * from employees.employees ;
</code></pre>


5.Job Propreties File(job.properties) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>user.name=mapred
oozie.use.system.libpath=true
oozie.wf.application.path=${nameNode}/user/oozie/workflow/practice_03
queueName=default
nameNode=hdfs://sandbox-hdp.hortonworks.com:8020
oozie.libpath=/user/oozie/share/lib/lib_20180201102929/sqoop
jobTracker=sandbox-hdp.hortonworks.com\:8032
</code></pre>

6.oozie sharelib update
----------------------------------------------------------------------------------------------------------------------------
<pre><code>[root@sandbox-hdp practice_03]# su oozie
[oozie@sandbox-hdp practice_03]$ oozie admin -sharelibupdate
[ShareLib update status]
	sharelibDirOld = hdfs://sandbox-hdp.hortonworks.com:8020/user/oozie/share/lib/lib_20180201102929
	host = http://sandbox-hdp.hortonworks.com:11000/oozie
	sharelibDirNew = hdfs://sandbox-hdp.hortonworks.com:8020/user/oozie/share/lib/lib_20180201102929
	status = Successful
</code></pre>
