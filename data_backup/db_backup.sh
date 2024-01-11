#! /bin/bash

today=`date +%Y%m%d`
last_month=$(date -d "$today -7 days" +%Y%m%d)
back_dir=      #edit me

if [ ! -d $back_dir ]; then
    mysqldump --login-path=root --all-databases > $back_dir/mysql_$today.sql   #Before excute this command you should configure mysql_config_editor
else
    mkdir $back_dir
    mysqldump --login-path=root --all-databases > $back_dir/mysql_$today.sql   #Before excute this command you should configure mysql_config_editor    
fi    

files=$(find ${back_dir} -mtime +7)
echo $files

for file in $files; do
    rm -rf $back_dir/$file
done    

