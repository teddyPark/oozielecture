ALTER TABLE weblogs.access_orc DROP IF EXISTS PARTITION (ymd=${YMD});

INSERT OVERWRITE TABLE weblogs.access_orc PARTITION (ymd=${YMD})
SELECT host, identity, userid,
         cast(from_unixtime(UNIX_TIMESTAMP(accesstime,'[dd/MMM/yyyy:HH:mm:ss Z]')) as timestamp) as accesstime,
         request, status, size, referer, agent
FROM weblogs.access_log
WHERE etl_ymd=${YMD};
