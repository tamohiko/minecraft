#!/bin/bash

# Settings
USERNAME='minecraft'
SERVICE='minecraft_server.jar'
MAX_MEM=1024
MIN_MEM=1024



cd /opt/minecraft

ME=`whoami`

if [ $ME == $USERNAME ] ; then
  if pgrep -u $USERNAME -f $SERVICE > /dev/null
    then
      echo "$SERVICE is already running!"
    else
      echo "Starting $SERVICE..."
      screen -AmdS minecraft java -Xmx${MAX_MEM}M -Xms${MIN_MEM}M -jar $SERVICE nogui
    fi
  else
    echo "Please run the minecraft user."
fi
