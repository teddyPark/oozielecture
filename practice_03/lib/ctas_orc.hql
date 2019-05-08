DROP TABLE IF EXISTS employees.employees_orc;
CREATE TABLE employees.employees_orc STORED AS ORC AS SELECT * from employees.employees ;
