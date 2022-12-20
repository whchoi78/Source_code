#! /bin/bash

DAY=$(date +%Y%m%d)
#YESTERDAY=$(date +%Y%m%d --date '1days ago')
#SOURCE="/app"      #please edit here


#if [ -e /backup/web01_$DAY ] ; then
#       rm -rf /backup/web01_$DAY
#fi
#rsync -avz $SOURCE /backup/$TARGET

if [ -e /app/files ] ; then
rsync -avz --exclude 'files' /app /NAS_Backup/$HOSTNAME >> /NAS_Backup/logs/$HOSTNAME/$DAY.log
else
rsync -avz /app /NAS_Backup/$HOSTNAME >> /NAS_Backup/logs/$HOSTNAME/$DAY.log
fi

#if [ -e /backup/logs/$HOSTNAME/logs_$YESTERDAY ] ; then
#       rm -rf /backup/logs_$YESTERDAY
#fi