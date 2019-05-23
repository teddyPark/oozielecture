SK BigData Academy - oozie/hive 를 이용한 ETL 
============================================

Virtual box 접속을 위한 hosts 설정
--------------------------------------------

C:\Windows\System32\drivers\etc\hosts 파일을 관리자 권한으로 open 하고 아래의 host 를 추가하고 저장

<pre><code> 127.0.0.1    sandbox-hdp.hortonworks.com </code></pre>


Virtual box 접속하기
--------------------------------------------

1. Sandbox-hdp Terminal 접속(SSH)

<pre>
id : root
password : hadoop
host : sandbox-hdp.hortonworks.com
port : 2222
</pre>

<pre><code>ssh -p 2222 root@sanbox-hdp.hortonworks.com </code></pre>

2. Sandbox-hdp Web terminal 접속(web)   (root/hadoop)
> http://sandbox-hdp.hortonworks.com:4200/

3. Sandbox-hdp Ambari Dashboard (web)   (admin/hadoop)
> http://sandbox-hdp.hortonworks.com:8080
