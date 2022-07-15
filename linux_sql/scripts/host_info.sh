#! /bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" != "5" ]; then
    echo "You must provide five args."
else
    echo "Welcome!"
fi

lscpu_out=$(lscpu)
fr=$(free)

hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out"  | egrep "^Model:" | awk '{print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out"  | egrep "^CPU MHz:" | awk '{print $3}' | xargs)
L2_cache=$(echo "$lscpu_out"  | egrep "^L2 cache:" | awk '{print $3}' | xargs)
total_mem=$(echo "$fr"  | egrep "^Mem:" | awk '{print $2}' | xargs)
timestamp=`date +%Y-%m-%d" "%H:%M:%S`

insert_stmt="INSERT INTO host_info(hostname,cpu_number,cpu_architecture,cpu_model,cpu_mhz,L2_cache,total_mem,timestamp) VALUES('$hostname',$cpu_number,'$cpu_architecture','$cpu_model',$cpu_mhz,'$L2_cache',$total_mem,'$timestamp')";

export PGPASSWORD=$psql_password;

psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?
