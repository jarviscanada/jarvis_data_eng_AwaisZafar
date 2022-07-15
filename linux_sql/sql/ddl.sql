\c host_agent;

CREATE TABLE IF NOT EXIST PUBLIC.host_info(id SERIAL NOT NULL UNIQUE PRIMARY KEY,hostname VARCHAR(60) NOT NULL,cpu_number int NOT NULL,cpu_architecture VARCHAR(60) NOT NULL,cpu_model VARCHAR(60) NOT NULL,cpu_mhz NUMERIC(8,4) NOT NULL,L2_cache int NOT NULL,total_mem int NOT NULL,timestamp TIMESTAMP NOT NULL);

INSERT INTO host_info VALUES(1,'spry-framework-236416.internal',1,'x86_64','Intel(R) Xeon(R) CPU @ 2.30GHz',2300.000,256,601324,'2019-05-29 17:49:53');

CREATE TABLE IF NOT EXIST PUBLIC.host_usage(timestamp TIMESTAMP NOT NULL,host_id SERIAL NOT NULL REFERENCES host_info(id),memory_free int NOT NULL,cpu_idle int NOT NULL,cpu_kernel int NOT NULL,disk_io int NOT NULL,disk_available int NOT NULL);

INSERT INTO host_usage VALUES('2019-05-29 16:53:28',1,256,95,0,0,31220);


