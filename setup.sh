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

echo "***************************start to create datanodes in slave***************************"
for F in {1..3} ;do docker exec $master_container sh -c "export MYSQL_PWD='$root_password';mysql -u root -e 'drop database db$F;'"; done
for F in {1..3} ;do docker exec $master_container sh -c "export MYSQL_PWD='$root_password';mysql -u root -e 'create database db$F;'"; done
docker exec $slave_container sh -c 'export MYSQL_PWD='$root_password';mysql -u root -e "show databases;"'
echo "***************************datanodes created***************************"

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


echo "***************************start to test mycat***************************"
init_table_stmt="
use ego;

create table test{
  id int(10) primary key auto_increment,
  name varchar(20)
};

insert into test(name) values('a');
insert into test(name) values('b');
insert into test(name) values('c');
insert into test(name) values('d');
insert into test(name) values('e');
insert into test(name) values('f');
insert into test(name) values('g');
insert into test(name) values('h');
insert into test(name) values('i');

select * from test;
"

check_table_stmt="
use db1;
select * from test;
use db2;
select * from test;
use db3;
select * from test;
"

drop_table_stmt="
use ego;
drop table test;
"

docker exec $mycat_container sh -c "export MYSQL_PWD='$root_password';mysql -u root -P8066 -e '$init_table_stmt'"
docker exec $slave_container sh -c "export MYSQL_PWD='$root_password';mysql -u root -e '$check_table_stmt'"
docker exec $mycat_container sh -c "export MYSQL_PWD='$root_password';mysql -u root -P8066 -e '$drop_table_stmt'"
echo "***************************mycat tested***************************"


echo "success"

exit 0