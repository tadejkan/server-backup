DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/constants.sh"

export PGPASSWORD="$POSTGRES_PASSWORD"
date_str=`date`
date_day=`date +%d`
for db_name in `psql --host $POSTGRES_HOST --port $POSTGRES_PORT --username $POSTGRES_USER -tAw -c "SELECT datname FROM pg_database WHERE datistemplate = false"`
do
	echo "[$date_str] Dumping $db_name" >> log.txt
	
	curr_date=`date +%Y-%m-%d`
	name="postgres-$db_name-$curr_date.xz"
	`pg_dump --host $POSTGRES_HOST --port $POSTGRES_PORT --username $POSTGRES_USER -w --format plain $db_name | xz > $name`
	`gsutil/gsutil cp $name $GS_WEEKLY_BUCKET/postgres/$curr_date/$name`
	if [[ date_day -eq 1 ]]; then
		`gsutil/gsutil cp $GS_WEEKLY_BUCKET/postgres/$curr_date/$name $GS_MONTHLY_BUCKET/postgres/$name`
	fi
	rm -f "$name"
done

