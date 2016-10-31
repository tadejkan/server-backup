#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/constants.sh"

log_tag='backup_gogs'

if [ `date +%u` -eq 1 ]; then is_monday=1; else is_monday=0; fi;
if [[ is_monday -eq 1 && `date +%e` -lt " 8" ]]; then is_first_monday=1; else is_first_monday=0; fi;
for dir_name in `ls -d $GOGS_ROOT/*/`; do
	if [ ! -z "$dir_name" ]; then
		space_available=`df -k ./ | tail -1 | awk '{print $4}'`
		size=`du -s "$dir_name" | cut -f1`
		if [[ size -gt space_available ]]; then
			log 'WARNING' $log_tag "Too large: $dir_name"
		else
			name=$(basename "$dir_name")
			incremental_file="./incrementals/gogs-$name.snar" #name should be without date
			curr_date=`date +%Y-%m-%d`
			name="gogs-$name-$curr_date"
			
			if [[ is_monday -eq 1 ]]; then
				rm -f "$incremental_file"
			fi
			
			if [[ ! -f $incremental_file ]]; then
				name="$name-full"
			fi
			
			filename="./$name.tar.xz"

			log 'INFO' $log_tag "Compressing $name"
			log_contents=`tar --create --xz --file=$filename $GOGS_EXCLUDES --listed-incremental=$incremental_file $dir_name 2>&1`
			log 'INFO' $log_tag "tar log: $log_contents"
			
			log_contents=`$GS_UTIL_BINARY_PATH cp $filename $GS_WEEKLY_BUCKET/gogs/$curr_date/$name.tar.xz 2>&1`
			log 'INFO' $log_tag "gs_util log: $log_contents"
			
			if [[ is_first_monday -eq 1 ]]; then
				log_contents=`$GS_UTIL_BINARY_PATH cp $GS_WEEKLY_BUCKET/gogs/$curr_date/$name.tar.xz $GS_MONTHLY_BUCKET/gogs/$name.tar.xz 2>&1`
				log 'INFO' $log_tag "gs_util log: $log_contents"
			fi
			
			rm -f "$filename"
		fi
	fi
done

