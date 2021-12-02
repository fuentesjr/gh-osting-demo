#!/bin/bash

docker-compose down
rm -rf ./primary/data/*
rm -rf ./replica/data/*
docker-compose build
docker-compose up -d

until docker exec mysql_primary sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_primary database connection..."
    sleep 4
done

priv_stmt='GRANT REPLICATION REPLICA ON *.* TO "mydb_replica_user"@"%" IDENTIFIED BY "mydb_replica_pwd"; FLUSH PRIVILEGES;'
docker exec mysql_primary sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt'"

until docker-compose exec mysql_replica sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_replica database connection..."
    sleep 4
done

docker-ip() {
    docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

MS_STATUS=`docker exec mysql_primary sh -c 'export MYSQL_PWD=111; mysql -u root -e "SHOW PRIMARY STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_replica_stmt="CHANGE PRIMARY TO PRIMARY_HOST='$(docker-ip mysql_primary)',PRIMARY_USER='mydb_replica_user',PRIMARY_PASSWORD='mydb_replica_pwd',PRIMARY_LOG_FILE='$CURRENT_LOG',PRIMARY_LOG_POS=$CURRENT_POS; START REPLICA;"
start_replica_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_replica_cmd+="$start_replica_stmt"
start_replica_cmd+='"'
docker exec mysql_replica sh -c "$start_replica_cmd"

docker exec mysql_replica sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW REPLICA STATUS \G'"
