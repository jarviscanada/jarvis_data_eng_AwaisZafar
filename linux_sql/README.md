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

## Scripts
Shell script description and usage (use markdown code block for script usage)
- psql_docker.sh
- host_info.sh
- host_usage.sh
- crontab
- queries.sql (describe what business problem you are trying to resolve)

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
