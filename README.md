SK BigData Academy - oozie/hive 를 이용한 ETL 
============================================

Virtual box 접속을 위한 hosts 설정
--------------------------------------------

C:\Windows\System32\drivers\etc\hosts 파일을 관리자 권한으로 open 하고 아래의 host 를 추가하고 저장


> 127.0.0.1    sandbox-hdp.hortonworks.com


Virtual box 접속하기
--------------------------------------------

1. Sandbox-hdp Terminal 접속(SSH)
id : root
password : hadoop
port : 2222

> ssh -p 2222 root@sanbox-hdp.hortonworks.com 

2. Sandbox-hdp Web terminal 접속(web)
> http://sandbox-hdp.hortonworks.com:4200/

3. Sandbox-hdp Ambari Dashboard (web)
> http://sandbox-hdp.hortonworks.com:8080
