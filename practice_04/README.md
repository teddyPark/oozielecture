1.Coordinator File(coordinator.xml) 
----------------------------------------------------------------------------------------------------------------------------

```xml
<coordinator-app xmlns:sla="uri:oozie:sla:0.2" xmlns="uri:oozie:coordinator:0.4" name="RITA_coordinator" 
                 frequency="0 1 1 1 *" start="2000-01-01T01:00+0900" end="2008-01-01T02:00+0900" 
                 timezone="Asia/Seoul">
    <controls>
        <timeout>60</timeout>
    </controls>
    <datasets>
        <dataset name="data" frequency="${coord:months(12)}" initial-instance="2000-01-01T01:00+0900" 
                 timezone="Asia/Seoul">
            <uri-template>hdfs://sandbox-hdp.hortonworks.com/stage-data/RITA_Data/${YEAR}</uri-template>
            <done-flag>_SUCCESS</done-flag>
        </dataset>
    </datasets>
    <input-events>
        <data-in name="input" dataset="data">
           <instance>${coord:current(0)}</instance>
        </data-in>
    </input-events>
    <action>
        <workflow>
            <app-path>/user/oozie/workflow/practice_02/workflow.xml</app-path>
            <configuration>
                <property>
                    <name>YEAR</name>
                    <value>${coord:formatTime(coord:nominalTime(),'yyyy')}</value>
                </property>
            </configuration>
        </workflow>
    </action>
</coordinator-app>
```
2.Job Propreties File(job.properties) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>user.name=mapred
oozie.use.system.libpath=true
oozie.coord.application.path=${nameNode}/user/oozie/workflow/practice_04
queueName=default
nameNode=hdfs://sandbox-hdp.hortonworks.com:8020
oozie.libpath=
jobTracker=sandbox-hdp.hortonworks.com\:8032
</code></pre>

3.oozie job 실행
----------------------------------------------------------------------------------------------------------------------------

1. workflow 경로를 HDFS 로 복사
<pre><code>[root@sandbox-hdp oozielecture]# hadoop fs -put -f practice_04 /user/oozie/workflow/.
</code></pre>

2. oozie job run CLI command 실행
<pre><code>[root@sandbox-hdp practice_04]# oozie job -config job.properties -run
</code></pre>
