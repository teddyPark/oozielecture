1.Bundle File(bundle.xml)
----------------------------------------------------------------------------------------------------------------------------
```xml
<bundle-app name='APPNAME' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns='uri:oozie:bundle:0.2'>
   <coordinator name="accesslog" enabled="true">
       <app-path>${nameNode}/user/oozie/workflow/lecture_05/coordinator.xml</app-path>
   </coordinator>
   <coordinator name='stat_accesslog' enabled="true">
       <app-path>${nameNode}/user/oozie/workflow/lecture_06/coordinator.xml</app-path>
   </coordinator>
</bundle-app>
```

2.Bundle Job properties File(job.properties)
----------------------------------------------------------------------------------------------------------------------------
<pre><code>user.name=mapred
oozie.use.system.libpath=true
oozie.bundle.application.path=${nameNode}/user/oozie/workflow/lecture_07
queueName=default
nameNode=hdfs://sandbox-hdp.hortonworks.com:8020
oozie.libpath=
jobTracker=sandbox-hdp.hortonworks.com\:8032
</code></pre>
