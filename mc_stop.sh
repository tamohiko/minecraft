#!/bin/bash

SERVICE='minecraft_server.jar'
USERNAME='minecraft'


cd /opt/minecraft

ME=`whoami`

if [ $ME == $USERNAME ] ; then
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      echo "Stopping $SERVICE"
      screen -p 0 -S minecraft -X eval 'stuff "/say SERVER SHUTTING DOWN IN 10 SECONDS. Saving map..."\015'
      screen -p 0 -S minecraft -X eval 'stuff "/save-all"\015'
      sleep 10
      screen -p 0 -S minecraft -X eval 'stuff "/stop"\015'
      sleep 7
      echo "Stopped minecraftserver"
    else
      echo "$SERVICE was not runnning."
  fi
else
  echo "Please run the minecraft user."
fi
