--LOAD DATA INPATH '/stage-data/weblogs/access/${ETL_YMD}/*.LOG' INTO TABLE weblogs.access_log 
--       PARTITION(etl_ymd=${ETL_YMD});
ALTER TABLE access_log ADD IF NOT EXISTS PARTITION (etl_ymd='${ETL_YMD}') LOCATION  
         '/stage-data/weblog/access/${ETL_YMD}';
