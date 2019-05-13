.Workflow File(workflow.xml) 
----------------------------------------------------------------------------------------------------------------------------

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workflow-app name="sample" xmlns="uri:oozie:workflow:0.5" xmlns:sla="uri:oozie:sla:0.2">
   <global/>
   <start to="JAVA_001"/>
   <kill name="Kill">
      <message>Action Failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
   </kill>
   <action name="JAVA_001">
        <java>
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <prepare/>
            <configuration>
                <property>
                    <name>mapreduce.job.queue.name</name>
                    <value>${queueName}</value>
                </property>
            </configuration>
            <main-class>Sleep</main-class>
            <java-opts/>
            <arg>${sleepTime}</arg>
            <file>lib/Sleep.jar</file>
            <capture-output/>
        </java>
        <ok to="end"/>
        <error to="Kill"/>
   </action>
   <end name="end"/>
</workflow-app>
```

2.Job Propreties File(job.properties) 생성
----------------------------------------------------------------------------------------------------------------------------
<pre><code>user.name=mapred
oozie.use.system.libpath=true
oozie.wf.application.path=${nameNode}/user/oozie/workflow/sample
queueName=default
nameNode=hdfs://sandbox-hdp.hortonworks.com:8020
oozie.libpath=
jobTracker=sandbox-hdp.hortonworks.com\:8032
sleepTime=5
</code></pre>
</code></pre>
