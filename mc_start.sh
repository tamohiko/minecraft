#!/bin/bash

USERNAME='minecraft'
SERVICE='minecraft_server.jar'

cd /opt/minecraft

ME=`whoami`

if [ $ME == $USERNAME ] ; then
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      echo "$SERVICE is already running!"
    else
      echo "Starting $SERVICE..."
      screen -AmdS minecraft java -Xmx1024M -Xms1024M -jar minecraft_server.jar nogui
    fi
  else
    echo "Please run the minecraft user."
fi
