Docker MySQL primary-replica replication
========================

MySQL primary-replica replication with using Docker.

## Run

To run this examples you will need to start containers with "docker-compose"
and after starting setup replication. See commands inside ./build.sh.

#### Create 2 MySQL containers with primary-replica row-based replication

```
./build.sh
```

#### Make changes to primary

```
docker exec mysql_primary sh -c "export MYSQL_PWD=111; mysql -u root mydb -e 'create table code(code int); insert into code values (100), (200)'"
```

#### Read changes from replica

```
docker exec mysql_replica sh -c "export MYSQL_PWD=111; mysql -u root mydb -e 'select * from code \G'"
```

## Troubleshooting

#### Check Logs

```
docker-compose logs
```

#### Start containers in "normal" mode

> Go through "build.sh" and run command step-by-step.

#### Check running containers

```
docker-compose ps
```

#### Clean data dir

```
rm -rf ./primary/data/*
rm -rf ./replica/data/*
```

#### Run command inside "mysql_primary"

```
docker exec mysql_primary sh -c 'mysql -u root -p111 -e "SHOW PRIMARY STATUS \G"'
```

#### Run command inside "mysql_replica"

```
docker exec mysql_replica sh -c 'mysql -u root -p111 -e "SHOW REPLICA STATUS \G"'
```

#### Enter into "mysql_primary"

```
docker exec -it mysql_primary bash
```

#### Enter into "mysql_replica"

```
docker exec -it mysql_replica bash
```
