#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/constants.sh"

log_tag='backup_postgres'

export PGPASSWORD="$POSTGRES_PASSWORD"
date_str=`date`
date_day=`date +%d`
for db_name in `psql --host $POSTGRES_HOST --port $POSTGRES_PORT --username $POSTGRES_USER -tAw -c "SELECT datname FROM pg_database WHERE datistemplate = false"`
do
	log 'INFO' $log_tag "Dumping $db_name"
	
	curr_date=`date +%Y-%m-%d`
	name="postgres-$db_name-$curr_date.xz"
	
	log_contents=`pg_dump --host $POSTGRES_HOST --port $POSTGRES_PORT --username $POSTGRES_USER -w --format plain $db_name | xz > $name 2>&1`
	log 'INFO' $log_tag "pg_dump log: $log_contents"
	
	log_contents=`$GS_UTIL_BINARY_PATH cp $name $GS_WEEKLY_BUCKET/postgres/$curr_date/$name 2>&1`
	log 'INFO' $log_tag "gs_util log: $log_contents"
	
	if [[ date_day -eq 1 ]]; then
		log_contents=`$GS_UTIL_BINARY_PATH cp $GS_WEEKLY_BUCKET/postgres/$curr_date/$name $GS_MONTHLY_BUCKET/postgres/$name 2>&1`
		log 'INFO' $log_tag "gs_util log: $log_contents"
	fi
	rm -f "$name"
done

