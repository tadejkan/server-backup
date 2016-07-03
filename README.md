# Backup for servers using Google Cloud Storage (Nearline)

Creates a daily (full) backup of DBs.

Creates a weekly full backup of files and daily diff.

Creates monthly full backups of DBs and files (on first Monday of the month).

## Why?

Because I needed a backup solution for my servers, but couldn't find one that would suite me.

## Prerequisites

- ```xz``` command installed on your machine (for compressing data).

- ```mysqldump``` and ```pg_dump``` commands installed if you wish to backup MySQL and PostgreSQL.

- Setup Google Cloud Storage with one project created, for backuping purposes.

## Installation

1. Create a folder somewhere on your server (e.g., ```/root/backups/```) and upload files from Git into it. You can do so either manually by downloading files to your computer and uploading them, or you can do it by running these commands:
	```
	$ wget https://github.com/tadejkan/server-backup/archive/master.zip
	$ unzip master.zip
	$ mv server-backup-master backups
	```

2. Make backup files executable by running

	```
	$ chmod +x backup*.sh create_bucket.sh
	```

3. Download Google's ```gsutil```, install it and configure it, following instructions at https://cloud.google.com/storage/docs/gsutil_install (you'll need a Google Cloud account with at least one project).
	
	You can also install it by simply extracting it into a directory (and configuring it, by calling ```gsutil config```, of course).
	
	**Note: by default, backup scripts search for ```gsutil``` as being in ```gsutil``` folder, directly under backup folder (e.g., ```/root/backups/```).**
	
	**If you didn't install it this way, then please modify ```GS_UTIL_BINARY_PATH``` in ```constants.sh```.**
	
4. Edit ```constants.sh``` and change info to match your environment.
	
	At the very least, you have to change ```GS_MONTHLY_BUCKET``` and ```GS_WEEKLY_BUCKET``` variables.
	
	According to Google, these have to be unique, not just for your account, but globally as well. See https://cloud.google.com/storage/docs/bucket-naming#requirements for more information.
	
5. Run ```./create_bucket.sh``` to create appropriate buckets.
	
	Two 404 errors are expected to be displayed, because the script checks for weekly and monthly bucket existence.
	
	If there are any other errors, please resolve them before continuing.

6. Add this line to your CRON (change backups folder if necessary):

	```0 1 * * * cd /root/backups/ && ./backup_postgres.sh && ./backup_mysql.sh && ./backup_sites.sh```
	
	If you only want to backup certain things, simply remove the rest. For example, if you only wanted to backup MySQL, your CRON would look like this:
	
	```0 1 * * * cd /root/backups/ && ./backup_mysql.sh```

7. That's it; wait a few days and verify everything's still working (uploads showing up on Google Cloud Storage).

## Restoring

### DB

1. Download newest backups of DBs you want to restore.

2. Extract somewhere.

3. Use appropriate commands (```mysql``` or ```pg_restore```) to restore DB from extracted backup.

### Files

1. Download newest full backups.

2. Download all non-full (incremental) backups newer than full backups.

3. Use this command to extract full backup

	(you can add ```--strip-components NUMBER``` if you want to extract to a different folder than the one it was backed up from)
	
	```
	$ tar -xpf backup_name-full.tar.xz
	```

4. Use this command on every incremental backup to restore it (commands must be executed on incremental backups in the correct order - by date, ascending)

	(you can add ```--strip-components NUMBER``` if you want to extract to a different folder than the one it was backed up from)
	
	```
	$ tar -xpf backup_name.tar.xz
	```

## FAQ

- How often can/should the script be run?

	The minimum required to function properly, is every first Monday of each month.
	
	If you want to run it weekly, then do so on Mondays, because it takes a full snapshot then.

	Otherwise, it is recommended to run it daily.

	**Warning: the script must not run multiple times a day, without changing the naming scheme, because it currently relies on date being unique; otherwise it'll overwrite existing files.**

##Author
- Email: tadej@ncode.si
- GitHub: https://github.com/tadejkan

## Contributing

Pull requests are welcome.

## License

This content is released under the (http://opensource.org/licenses/MIT) MIT License.
