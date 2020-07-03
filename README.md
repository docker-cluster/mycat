# mycat

## 注意

部署本项目前需要先部署mysql-cluster

``` bash
git clone https://github.com/docker-cluster/mysql-cluster.git
cd mysql-cluster
chmod +x setup.sh
./setup.sh
```

## 说明

版本：1.6.7.4

端口映射: 38066:8066, 39066:9066

网络：bridge

## 部署

``` bash
git clone https://github.com/docker-cluster/mycat.git
cd mycat
chmod +x setup.sh
./setup.sh
```

## 测试

step1: 通过客户端新建数据库连接到ip:38066，然后创建test表并插入10条数据。

``` sql
use ego;
drop table test;
create table test(
  id int(10) primary key,
  name varchar(20),
  starttime timestamp default now()
);

insert into TEST(id,name) values(1,'a'),(2,'b'),(3,'c'),(4,'d'),(5,'e'),(6,'f'),(7,'g'),(8,'h'),(9,'i'),(10,'j');

select * from test;

```

step2: 在从库中查询datanode

``` sql
use db1;
select * from test;
use db2;
select * from test;
use db3;
select * from test;
```

step3: 清理

``` sql
use ego;
drop table test;
```
