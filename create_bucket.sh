DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/constants.sh"

files=`$GS_UTIL_BINARY_PATH ls $GS_MONTHLY_BUCKET`
exit_code=$?
if [[ exit_code -eq 1 ]]; then
	echo "Creating monthly bucket"
	`$GS_UTIL_BINARY_PATH mb -c NL -l EU $GS_MONTHLY_BUCKET`
	`$GS_UTIL_BINARY_PATH lifecycle set lifecycle_config_monthly.json $GS_MONTHLY_BUCKET`
fi

files=`$GS_UTIL_BINARY_PATH ls $GS_WEEKLY_BUCKET`
exit_code=$?
if [[ exit_code -eq 1 ]]; then
	echo "Creating weekly bucket"
	`$GS_UTIL_BINARY_PATH mb -c NL -l EU $GS_WEEKLY_BUCKET`
	`$GS_UTIL_BINARY_PATH lifecycle set lifecycle_config_weekly.json $GS_WEEKLY_BUCKET`
fi
