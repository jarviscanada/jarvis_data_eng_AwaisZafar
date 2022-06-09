# Introduction
(about 150-200 words)
Discuss the design of the project. What does this project/product do? Who are the users? What are the technologies you have used? (e.g. bash, docker, git, etc..)

The design of project is based on the requirement of getting the specific hardware specification(CPU/Memory usage) data in real time from the system and store it into RDBMS database. The Jarvis linux cluster administration team manages a cluster of 10 nodes/servers running CentOS 7 which are connected through a switch and able to communicate through internal IPV4 addresses. In order to record the hardware specifications of each node and monitor node resource usages in real time, the bash scripts were created in the linux command line (CLI) to extract the data and then PSQL instance was initialized in CLI through the docker containers and then RDBMS database was created to save and organize the extracted data into the tables over one minute interval which was done by setting up Crontab script. The data saved in RDCMS database will later be used by the LCA team to generate reports for future resource planning purposes. And lastly the project was saved into a github repository through Linus CLI.  

# Quick Start
Use markdown code block for your quick-start commands
- Start a psql instance using psql_docker.sh
```
psql -h localhost -U postgres -d postgres -W
./scripts/psql_docker.sh start
```
- Create tables using ddl.sql
```
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
```
- Insert hardware specs data into the DB using host_info.sh
```
./scripts/host_info.sh "localhost" 5432 "host_agent" "postgres" "password"
```
- Insert hardware usage data into the DB using host_usage.sh
```
./scripts/host_usage.sh "localhost" 5432 "host_agent" "postgres" "password"
```
- Crontab setup
```
bash> crontab -e

* * * * * bash /home/centos/dev/jrvs/bootcamp/linux_sql/host_agent/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log

crontab -l

validate result from psql instance as follows:

Select * From host_usage;
```


# Implemenation
Discuss how you implement the project.
Two bash scrits (`host_info.sh` and `host_usage.sh`) were created using `vim` editor to extract the data from the data provided by `vmstat` command in Linux command line and then psql instance was provisioned using docker and latest version of postgres was pulled and then a new container was created using psql image which was named `jrvs-psql` and then postgres sql was used to create `ddl.sql` in Linux CLI which creates the table for `host_usage.sh` to store data into RDBMS database. And in order to extract and save the data from `host_usage.sh` into RDBMS database every minute the crontab was setup using `host_usage.sh` shell script which in results saves the data into the database every minute. Also, SQL queries were created for the LCA team so that the cluster can be managed better and plan for future resources. 

## Architecture
Draw a cluster diagram with three Linux hosts, a DB, and agents (use draw.io website). Image must be saved to the `assets` directory.

![cluster diagram](https://i.ibb.co/r2xfmXj/linux-sql-drawio.png)

## Scripts
Shell script description and usage (use markdown code block for script usage)
- psql_docker.sh

```#! /bin/sh // used to tell the Linux OS which interpreter to use to parse the rest of the file.

cmd=$1  //Getting the 1st argument
db_username=$2//Getting the second argument from the user which is the username
db_password=$3//Getting the third argument from the user which is the password

sudo systemctl status docker || systemctl start docker //Checking to see if the docker is running otherwise starting docker

container_status=$? //checking the status of the container

case $cmd in //User switch case to handle create|stop|start options
  create)
//checking if the container is already created
 if [ $container_status -eq 0 ]; then
		echo 'Container already exists'
		exit 1	
	fi
//checking if the correct number of arguments are entered
 if [ $# -ne 3 ]; then
    echo 'Create requires username and password'
    exit 1
  fi
       //creating container          
	docker volume create pgdata
	
	#creating a container using psql image with name=jrvs-psql
	docker run --name jrvs-psql -e POSTGRES_PASSWORD=$PGPASSWORD -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine

	exit $?
	;;
//checkking if container is created	
 if [ $container_status ...
  ...
	docker container $cmd jrvs-psql
	exit $?
	;;	
*)
	echo 'Illegal command'
	echo 'Commands: start|stop|create'
	exit 1
	;;
esac 
```

- host_info.sh

```#! /bin/bash // used to tell the Linux OS which interpreter to use to parse the rest of the file.

psql_host=$1 //getting the 1st argument from the user which is the hostname
psql_port=$2 //getting the 2nd argument from the user which the port number
db_name=$3 //getting the 3rd argument from the user which is the name of the database
psql_user=$4 //getting the 4th argument from the user which is the username of the psql instance
psql_password=$5 //getting the 5th argument from the user which the password for the psql instance

//Checking if the correct number of arguments are entered if not then print "You must provide five argument" otherwise print "Welcome!"
if [ "$#" != "5" ]; then
    echo "You must provide five args."
else
    echo "Welcome!"
fi

lscpu_out=$(lscpu) //storing the values from lscpu command into lscpu_out variable
fr=$(free) //storing values from free command into fr variable

hostname=$(hostname -f) //storing the current hostname into hostname variable

//extracting the specific values from lscpu and free commands and storing them into a relevant variable using egrep function which looks for the specified string

cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs) 
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out"  | egrep "^Model:" | awk '{print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out"  | egrep "^CPU MHz:" | awk '{print $3}' | xargs)
L2_cache=$(echo "$lscpu_out"  | egrep "^L2 cache:" | awk '{print $3}' | xargs)
total_mem=$(echo "$fr"  | egrep "^Mem:" | awk '{print $2}' | xargs)
timestamp=`date +%Y-%m-%d" "%H:%M:%S`

//defining a variable "insert_stmt" and assigning string of sql query

insert_stmt="INSERT INTO host_info(hostname,cpu_number,cpu_architecture,cpu_model,cpu_mhz,L2_cache,total_mem,timestamp) VALUES('$hostname',$cpu_number,'$cpu_architecture','$cpu_model',$cpu_mhz,'$L2_cache',$total_mem,'$timestamp')";

export PGPASSWORD=$psql_password;

psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt" //initiating a sql instance and saving the data extracted into the data base
exit $?
```
- host_usage.sh
```#!/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

hostname=$(hostname -f)
vm=$(vmstat)
fr=$(free)

memory_free=$(echo "$fr"  | egrep "^Mem:" | awk '{print $4}' | xargs)
cpu_idle=$(echo "$vm"  | egrep "1" | awk '{print $4}' | xargs)
cpu_kernel=$(echo "$vm"  | egrep "1" | awk '{print $14}' | xargs)
disk_io=$(echo "$vm"  | egrep "1" | awk '{print $10}' | xargs)
disk_available=$(echo "$fr"  | egrep "Mem:" | awk '{print $6}' | xargs)
timestamp=$(date +%Y-%m-%d" "%H:%M:%S)

host_id="(SELECT id FROM host_info WHERE hostname='$hostname')";

insert_stmt="INSERT INTO host_usage(timestamp,host_id,memory_free,cpu_idle,cpu_kernel,disk_io,disk_available) VALUES('$timestamp',$host_id,$memory_free,$cpu_idle,$cpu_kernel,$disk_io,$disk_available)"

export PGPASSWORD=$psql_password

psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?
```
- crontab
```
bash> crontab -e
* * * * * bash /home/centos/dev/jrvs/bootcamp/linux_sql/host_agent/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log
crontab -l
```
- queries.sql (describe what business problem you are trying to resolve)
```select cpu_number,id,total_mem
from host_info
order by total_mem desc;

CREATE FUNCTION round5(ts timestamp) RETURNS timestamp AS
$$
BEGIN
    RETURN date_trunc('hour', ts) + date_part('minute', ts):: int / 5 * interval '5 min';
END;
$$
    LANGUAGE PLPGSQL;

Select host_id,host_info.hostname,round5(host_usage.timestamp),AVG((host_info.total_mem)-(memory_free)) as avg_used_mem_percentage
from host_usage, host_info
group by host_id,host_info.hostname,host_usage.timestamp;
```

## Database Modeling
Describe the schema of each table using markdown table syntax (do not put any sql code)
- `host_info`
- `host_usage`

# Test
How did you test your bash scripts and SQL queries? What was the result?

# Deployment
How did you deploy your app? (e.g. Github, crontab, docker)

# Improvements
Write at least three things you want to improve 
e.g. 
- handle hardware update 
- blah
- blah
