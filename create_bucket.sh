#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/constants.sh"

log_tag='create_bucket'

files=`$GS_UTIL_BINARY_PATH ls $GS_MONTHLY_BUCKET 2>&1`
exit_code=$?
if [[ exit_code -eq 1 ]]; then
	log 'INFO' $log_tag 'Creating monthly bucket'
	log_contents=`$GS_UTIL_BINARY_PATH mb -c NL -l $GS_BUCKET_LOCATION $GS_MONTHLY_BUCKET 2>&1`
	log 'INFO' $log_tag "gs_util log: $log_contents"
	log_contents=`$GS_UTIL_BINARY_PATH lifecycle set lifecycle_config_monthly.json $GS_MONTHLY_BUCKET 2>&1`
	log 'INFO' $log_tag "gs_util log: $log_contents"
fi

files=`$GS_UTIL_BINARY_PATH ls $GS_WEEKLY_BUCKET 2>&1`
exit_code=$?
if [[ exit_code -eq 1 ]]; then
	log 'INFO' $log_tag 'Creating weekly bucket'
	log_contents=`$GS_UTIL_BINARY_PATH mb -c NL -l $GS_BUCKET_LOCATION $GS_WEEKLY_BUCKET 2>&1`
	log 'INFO' $log_tag "gs_util log: $log_contents"
	log_contents=`$GS_UTIL_BINARY_PATH lifecycle set lifecycle_config_weekly.json $GS_WEEKLY_BUCKET 2>&1`
	log 'INFO' $log_tag "gs_util log: $log_contents"
fi
