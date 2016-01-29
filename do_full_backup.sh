#!/bin/bash

SOURCE_FOLDER="/opt/data/backup/backup_folders"
OUTPUT_FOLDER="/opt/data/backup/backup_data"
CATALOGE_FOLDER="/opt/data/backup/backup_cataloge"
BACKUP_NAME="full_backup"
MAIL="your@mail.address"
MAX_SLICE_SIZE="45G"
BZIP_LEVEL="6"
LOGFILE="$(mktemp -t dar_output_XXX.txt)"
DATE="$(date +%Y-%m-%d)" 
TIME="$(date +%H-%M)"
MESSAGE=""

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
   MESSAGE="ERROR: At least one file with the same basename exists already in ${OUTPUT_FOLDER}/"
fi

if [ ! -z "$MESSAGE" ]; then
   echo $MESSAGE; exit 1
fi

DAR_MESSAGE="$(dar -Q -v -s $MAX_SLICE_SIZE -zbzip2:$BZIP_LEVEL -D -R $SOURCE_FOLDER -c "${OUTPUT_FOLDER}/${BACKUP_NAME}_${DATE}_${TIME}" -@ "${CATALOGE_FOLDER}/${BACKUP_NAME}_cataloge_${DATE}_${TIME}" &> $LOGFILE)"
ERROR_CODE=$?

if [ $ERROR_CODE -ne 0 ]; then
   mutt -s "Backup -($BACKUP_NAME)- exited with error(s)" -a $LOGFILE -- $MAIL <<EOM
   Hi Admin,
   the backup for $SOURCE_FOLDER exited with error code $ERROR_CODE. Please check on addtional actions. Detailed dar output see attached file.
   
   Best regards,
     your backup-script

   ---------
   $DAR_MESSAGE
EOM

else
   mutt -s "Backup -($BACKUP_NAME)- was successful" -a $LOGFILE -- $MAIL <<EOM
   Hi Admin,
   the backup for $SOURCE_FOLDER went fine. Details in the attached file.
   Please make sure to safely store the .dar files

   Best regards, 
     your backup-script

   ---------
   $DAR_MESSAGE
EOM
fi
