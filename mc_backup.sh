#!/bin/bash

SERVICE='minecraft_server.jar'
USERNAME='minecraft'
MC_PATH='/opt/minecraft'
BK_PATH='/home/minecraft/mc_backup'

BK_TIME=`date +%Y%m%d-%H%M%S`
BK_NAME="$BK_PATH/mc_backup_${BK_TIME}.tar"
BK_GEN="1420"

cd $MC_PATH

ME=`whoami`

if [ $ME == $USERNAME ] ; then
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      echo "Backup start minecraft data..."
      screen -p 0 -S minecraft -X eval 'stuff "/save-all"\015'
      sleep 10
      screen -p 0 -S minecraft -X eval 'stuff "/save-off"\015'
      tar cf $BK_NAME ./
      sleep 10
      screen -p 0 -S minecraft -X eval 'stuff "/save-on"\015'
      echo "minecraft_server backup compleate!"
      gzip -f $BK_NAME
      find $BK_PATH -name "mc_backup_*.tar.gz" -type f -mmin +$BK_GEN -exec rm {} \;
    else
      echo "$SERVICE was not runnning."
  fi
else
  echo "Please run the minecraft user."
fi
