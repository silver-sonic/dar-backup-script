#!/bin/bash

# Which folder cotains the data to be backuped
SOURCE_FOLDER="/opt/data/backup/backup_folders"

# Folder to place the dar backup files (those files must be saved to a secure place like a BluRay Dics)
OUTPUT_FOLDER="/opt/data/backup/backup_data"

# Folder containing all dar-cataloges for both full and incremental backups
CATALOGE_FOLDER="/opt/data/backup/backup_cataloge"

# Backup base name
BACKUP_NAME="backup"

# Receiver of statusmail
MAIL="your@mail.address"

# Maximum filesize for each dar-file (default 20G)
MAX_SLICE_SIZE="20G"

# Compression Level for Backup (0-9, default 6)
BZIP_LEVEL="6"

# reference backup is last incremental (inc) or the last full (full) backup (
REFERENCE="full"

LOGFILE="$(mktemp -t dar_output_XXX.txt)"

DATE="$(date +%Y-%m-%d)" 
TIME="$(date +%H-%M)"
MESSAGE=""

LAST_CATALOGE="$(ls -1 ${CATALOGE_FOLDER}/${REFERENCE}_${BACKUP_NAME}_cataloge* 2>/dev/null | sort -r | head -n1 | sed 's/\.[0-9]\{1,\}\.dar$//')"

if [ ! -e "$LAST_CATALOGE.1.dar" ]; then
   MESSAGE="ERROR: No old dar cataloge found. Wrong backup name or no full backup available?"
fi

if [ ! -r $SOURCE_FOLDER ]; then
   MESSAGE="ERROR: Source folder does not exist or is not readable."
fi

if [ ! -w $OUTPUT_FOLDER ]; then
   MESSAGE="ERROR: Output folder does not exist or is not writeable."
fi

if [ ! -w $CATALOGE_FOLDER ]; then
   MESSAGE="ERROR: Cataloge folder does not exist or is not writeabe."
fi

if [ "$(ls -A ${OUTPUT_FOLDER}/${BACKUP_NAME}* 2>/dev/null)" ]; then
   MESSAGE="ERROR: At least one file with the same basename exists already in ${OUTPUT_FOLDER}/\nMaybe the old backup files have not been removed?"
fi

if [ ! -z "$MESSAGE" ]; then
   echo $MESSAGE; exit 1
fi

DAR_MESSAGE="$(dar -Q -v -s $MAX_SLICE_SIZE -zbzip2:$BZIP_LEVEL -A $LAST_CATALOGE -D -R $SOURCE_FOLDER -c "${OUTPUT_FOLDER}/inc_${BACKUP_NAME}_${DATE}_${TIME}" -@ "${CATALOGE_FOLDER}/inc_${BACKUP_NAME}_cataloge_${DATE}_${TIME}" &> $LOGFILE)"

ERROR_CODE=$?

if [ $ERROR_CODE -ne 0 ]; then
   mutt -s "Backup -($BACKUP_NAME)- exited with error(s)" -a $LOGFILE -- $MAIL <<EOM
   Hi Admin,
   the backup for $SOURCE_FOLDER exited with error code $ERROR_CODE!

    Please check on addtional actions and the attached logfile.
  
   Best regards,
     your backup-script
   ------------
   $DAR_MESSAGE

EOM

else
   mutt -s "Backup -($BACKUP_NAME)- was successful" -a $LOGFILE -- $MAIL <<EOM
   Hi Admin,
   the backup for $SOURCE_FOLDER went fine. Details in the attached logfile.
   Please make sure to safely store the .dar files

   Best regards, 
     your backup-script

   ------------
   $DAR_MESSAGE
EOM
fi
