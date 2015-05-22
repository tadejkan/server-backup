#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/constants.sh"

log_tag='backup_mysql'

date_day=`date +%d`
for db_name in `mysql --host=$MYSQL_HOST -P $MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD -rBN -e "SHOW DATABASES WHERE \\\`Database\\\` NOT IN ('information_schema', 'performance_schema', 'mysql')"`
do
	log 'INFO' $log_tag "Dumping $db_name"
	
	curr_date=`date +%Y-%m-%d`
	name="mysql-$db_name-$curr_date.xz"
	
	log_contents=`mysqldump --host=$MYSQL_HOST -P $MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD $db_name | xz > $name 2>&1`
	log 'INFO' $log_tag "mysqldump log: $log_contents"
	
	log_contents=`$GS_UTIL_BINARY_PATH cp $name $GS_WEEKLY_BUCKET/mysql/$curr_date/$name 2>&1`
	log 'INFO' $log_tag "gs_util log: $log_contents"
	if [[ date_day -eq 1 ]]; then
		log_contents=`$GS_UTIL_BINARY_PATH cp $GS_WEEKLY_BUCKET/mysql/$curr_date/$name $GS_MONTHLY_BUCKET/mysql/$name 2>&1`
		log 'INFO' $log_tag "gs_util log: $log_contents"
	fi
	rm -f "$name"
done

