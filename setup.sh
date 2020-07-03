#!/bin/bash

cluster_user="slave"
cluster_password="123456"
root_password="123456"
master_container="mysql-master"
slave_container="mysql-slave"
mycat_container="mycat"
local_host="`hostname --fqdn`"
local_ip=`host $local_host 2>/dev/null | awk '{print $NF}'`

echo -e "\033[34mthree datanodes in one host.\033[0m"

echo "***************************start to init datanodes***************************"
#for F in {1..3} ;do docker exec $master_container sh -c "export MYSQL_PWD='$root_password';mysql -u root -e 'drop database db$F;'"; done
for F in {1..3} ;do docker exec $master_container sh -c "export MYSQL_PWD='$root_password';mysql -u root -e 'create database db$F;'"; done
docker exec $slave_container sh -c 'export MYSQL_PWD='$root_password';mysql -u root -e "show databases;"'
echo "***************************datanodes inited***************************"

echo "***************************start to configure mycat***************************"
schema_name="ego"
sed -i "s/{{ SCHEMANAME }}/$schema_name/" ./conf/schema.xml
sed -i "s/{{ MASTER1URL }}/$local_ip:33306/" ./conf/schema.xml
sed -i "s/{{ SLAVE1URL }}/$local_ip:33307/" ./conf/schema.xml
sed -i "s/{{ ROOTUSER }}/root/g" ./conf/schema.xml
sed -i "s/{{ ROOTPASS }}/$root_password/g" ./conf/schema.xml
sed -i "s/{{ SCHEMANAME }}/$schema_name/" ./conf/server.xml
sed -i "s/{{ ROOTPASS }}/$root_password/g" ./conf/server.xml
echo "***************************mycat configured***************************"

echo "***************************start to init mycat containers***************************"
docker-compose down
docker-compose up -d
echo "***************************mycat containers inited***************************"

echo "success"

exit 0