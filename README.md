# Backup for servers using Google Cloud Storage (Nearline)

Creates a daily (full) backup of DBs.

Creates a weekly full backup of files and daily diff.

Creates monthly full backups of DBs and files (on first Monday of the month).

## Why?

Because I needed a backup solution for my servers, but couldn't find one that would suite me.

## Requirements

- ```xz``` installed on your machine (for compressing data)

- ```mysqldump``` and ```pg_dump``` installed if you wish to backup MySQL and PostgreSQL

- setup Google Cloud Storage with one project created, for backuping purposes

## Installation

1. create a folder somewhere on your server (e.g., ```/root/backups/```) and copy these files into it

2. make backup files executable by running

	```
	$ chmod +x backup*.sh create_bucket.sh
	```

3. download ```gsutil``` and extract it (it should be in ```gsutil``` subdir, so that calling it from your backups directory is ```gsutil/gsutil```) in your backups directory

4. setup ```gsutil``` as you like (following Google's instructions on how to do it)

5. edit ```constants.sh``` and change info to match your environment

5. run ```./create_bucket.sh``` to create appropriate buckets

6. modify ```backup_postgres``` and ```backup_mysql``` with your passwords/hosts/ports

7. add this line to your CRON (modify if necessary):

	```0 1 * * * cd /root/backups/ && ./backup_postgres.sh && ./backup_mysql.sh && ./backup.sh```

8. that's it; wait a few days and verify everything's still working (uploads showing up on Google Cloud Storage)

## Restoring

### DB

1. download newest backups of DBs you want to restore

2. extract somewhere

3. use appropriate commands (```mysql``` or ```pg_restore```) to restore DB from extracted backup

### Files

1. download newest full backups

2. download all non-full (incremental) backups newer than full backups

3. use this command to extract full backup

	(you can add ```--strip-components NUMBER``` if you want to extract to a different folder than the one it was backed up from)
	
	```
	$ tar -xpf backup_name-full.tar.xz
	```

4. use this command on every incremental backup to restore it (commands must be executed on incremental backups in the correct order - by date, ascending)

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
