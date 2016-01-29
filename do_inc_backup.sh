#!/bin/bash

SOURCE_FOLDER="/opt/data/backup/backup_folders"
OUTPUT_FOLDER="/opt/data/backup/backup_data"
CATALOGE_FOLDER="/opt/data/backup/backup_cataloge"
BACKUP_NAME="backup"
MAIL="your@mail.address"
MAX_SLICE_SIZE="20G"
BZIP_LEVEL="6"

DATE="$(date +%Y-%m-%d)" 
TIME="$(date +%H-%M)"
MESSAGE=""

LAST_CATALOGE="$(ls -1 $CATALOGE_FOLDER/$REFERENCE*$BACKUP_NAME* 2>/dev/null | sort -r | head -n1 | sed 's/\.[0-9]\{1,\}\.dar$//')"

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

DAR_MESSAGE="$(dar -Q -v -s $MAX_SLICE_SIZE -zbzip2:$BZIP_LEVEL -A $LAST_CATALOGE -D -R $SOURCE_FOLDER -c "${OUTPUT_FOLDER}/inc_${DATE}_${TIME}_${BACKUP_NAME}" -@ "${CATALOGE_FOLDER}/inc_${DATE}_${TIME}_${BACKUP_NAME}_cataloge" 2>&1)"
ERROR_CODE=$?

if [ $ERROR_CODE -ne 0 ]; then
   mail -s "Backup -($BACKUP_NAME)- exited with error(s)" $MAIL <<EOM
   Hi Admin,
   the backup for $SOURCE_FOLDER exited with error code $ERROR_CODE. Please check on addtional actions. Detailed dar output:

   $DAR_MESSAGE
   
   Best regards,
     your backup-script
EOM

else
   mail -s "Backup -($BACKUP_NAME)- was successful" $MAIL <<EOM
   Hi Admin,
   the backup for $SOURCE_FOLDER went fine. Details at the end of the mail.
   Please make sure to safely store the .dar files

   Best regards, 
     your backup-script

   ------------
   
   $DAR_MESSAGE
EOM
fi
