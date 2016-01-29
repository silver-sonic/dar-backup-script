# dar-backup-script
This repository provides a small and simple bash script to create automatic backups with "dar". It also will send out e-mails for notification.

I use those small scripts to create bi-monthly full backups of my RAID5 device. Additionally the incremental script creates weekly differential backups based on the last full backup. The full backups are limited to 45 GByte (to fit on a double sided bluray disc). The weekly incremental/differential backup is limited to 20 GByte (and therefore will fit on a single side bluray). Both limites can be changed in the script easily.

For details about "dar" see: [Dar Homepage](http://dar.linux.free.fr)

# Files
There are three files with different purposes:

- do_full_backup.sh
- do_inc_backup_ref-full.sh
- do_inc_backup.sh

The first file is used to create the full backup. The second to create a incremental backup based on the last full backup. The last file is used to create a incremental based on the last (possibly) incremental backup.
