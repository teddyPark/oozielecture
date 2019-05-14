1.Create Table
---------------------------------------------------------------------------------------------------------------------------
<pre><code>CREATE EXTERNAL TABLE `weblogs.stat_access`(
   `host` string,                                                                       
   `count` int)
 PARTITIONED BY ( ymd string )
 STORED AS ORC
 LOCATION                                                                               
   'hdfs://sandbox-hdp.hortonworks.com:8020/stage-data/weblogs/stat_access';  
</code></pre>
