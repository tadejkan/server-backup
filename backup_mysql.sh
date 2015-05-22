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
	`mysqldump --host=$MYSQL_HOST -P $MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD $db_name | xz > $name`
	`$GS_UTIL_BINARY_PATH cp $name $GS_WEEKLY_BUCKET/mysql/$curr_date/$name`
	if [[ date_day -eq 1 ]]; then
		`$GS_UTIL_BINARY_PATH cp $GS_WEEKLY_BUCKET/mysql/$curr_date/$name $GS_MONTHLY_BUCKET/mysql/$name`
	fi
	rm -f "$name"
done

