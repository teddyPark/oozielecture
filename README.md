# oozie lecture
sk bigdata academy - oozie lecture 

## 1. set ambari password
1. ssh -p 2222 root@localhost  (root / hadoop)
2. sudo ambari-admin-password-reset 

https://ko.hortonworks.com/tutorial/learning-the-ropes-of-the-hortonworks-sandbox/#admin-password-reset

## 2. set oozie timezone
1. oozie > configs > custom oozie-site 
2. Add property.. >  oozie.processing.timezone=GMT+0900  


## 3. copy sample data
1. unzip sample_data.zip
2. cd sample_data
3. hadoop fs -mkdir /stage-data
4. hadoop fs -put * /stage-data/.

## extjs-2.2.zip
cp ext-2.2.zip /usr/hdp/current/oozie-server/libext/.

cd /usr/hdp/current/oozie-server/

bin/oozie-setup.sh prepare-war
