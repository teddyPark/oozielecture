LOAD DATA INPATH '/stage-data/RITA_Data/${ETL_YEAR}/*.csv' INTO TABLE practice.flight_data_tmp PARTITION(etl_year=${ETL_YEAR});
