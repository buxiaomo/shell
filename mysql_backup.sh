#!/bin/bash
# backup.sh test1 192.168.0.11 8000 root root raw
# backup.sh test2 192.168.0.11 3050 root root ecar

# 0 2 * * * /data/backup_mysql.sh test1 192.168.0.11 3050 root ecar@daocloud ecar
# 0 2 * * * /data/backup_mysql.sh test1 192.168.0.11 3052 root ecar@daocloud sso

backup_time=`date +%Y%m%d%H%M%S`
backup_dir='/data'

MySQL_Host=$2
MySQL_Port=$3
MySQL_User=$4
MySQL_Pass=$5
MySQL_DataBase=$6

for DB in `echo ${MySQL_DataBase} | sed 's/,/\n/g'`
do 
    # /splunk/mysql/orig_mysql/mysql
    [ -d ${backup_dir}/$1/${DB} ] || mkdir -p ${backup_dir}/$1/${DB}
    /usr/bin/mysqldump -h${MySQL_Host} \
        -P${MySQL_Port} \
        -u${MySQL_User} \
        -p${MySQL_Pass} ${DB} > ${backup_dir}/$1/${DB}/${backup_time}.sql
    # cd ${backup_dir}/$1/${DB}
    # tar -Jvcf ${backup_time}.sql.tar.xz ${backup_time}.sql
done
exit 0
