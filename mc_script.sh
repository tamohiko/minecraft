#!/bin/bash
#
# mincraft_server start/stop/backup script
#

# mincraft_server.jar 実行ユーザ
USERNAME='mcadmin'

# session名
SESSION_NAME='minecraft'

# minecraft_serverディレクトリ
MC_PATH='/opt/minecraft'

# 実行するminecraft_server.jar
SERVICE='server.jar'

# メモリ設定
XMX='1024M'
XMS='1024M'

## バックアップ用設定
# バックアップ格納ディレクトリ
BK_DIR="/home/$USERNAME/mc_backup"

# バックアップ取得時間
BK_TIME=`date +%Y%m%d-%H%M%S`

# 完全バックアップデータ名
FULL_BK_NAME="$BK_DIR/mc_full_backup_${BK_TIME}.tar.gz"

# 簡易パックアップデータ名
SIMPLE_BK_NAME="$BK_DIR/mc_simple_backup_${BK_TIME}.tar"

# 簡易バックアップ対象データ
BK_FILE="$MC_PATH/world \
  $MC_PATH/banned-ips.json \
  $MC_PATH/banned-players.json \
  $MC_PATH/ops.json \
  $MC_PATH/server.properties \
  $MC_PATH/usercache.json \
  $MC_PATH/whitelist.json"

# バックアップデータ保存数
BK_GEN="3"

cd $MC_PATH

if [ ! -d $BK_DIR ]; then
  mkdir $BK_DIR
fi

ME=`whoami`

if [ $ME != $USERNAME ]; then
  echo "Please run the $USERNAME user."
  exit
fi

# Minecraft 開始処理
start() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null; then
    echo "$SERVICE is already running!"
  else
    echo "Starting $SERVICE..."
    tmux new-session -d -s $SESSION_NAME
    tmux send-keys -t $SESSION_NAME:0 "java -Xmx$XMX -Xms$XMS -jar $SERVICE nogui" C-m
  fi
}

# Minecraft 停止処理
stop() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null; then
    echo "Stopping $SERVICE"
    tmux send-keys -t $SESSION_NAME:0 "say SERVER SHUTTING DOWN IN 10 SECONDS. Saving map..." C-m
    tmux send-keys -t $SESSION_NAME:0 "save-all" C-m
    sleep 10
    tmux send-keys -t $SESSION_NAME:0 "stop" C-m
    sleep 10
    echo "Stopped minecraftserver"
  else
    echo "$SERVICE is not running!"
    exit
  fi

  while :
   do
     if
      pgrep -u $USERNAME -f $SERVICE > /dev/null; then
      echo "Stopping $SERVICE"
      sleep 10
    else
      tmux kill-session -t $SESSION_NAME
      echo "Stoped $SERVICE"
      break
    fi
  done
}

# Minecraft 簡易バックアップ処理
s_backup() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null; then
    echo "Backup start minecraft data..."
    tmux send-keys -t $SESSION_NAME:0 "save-all" C-m
    sleep 10
    tmux send-keys -t $SESSION_NAME:0 "save-off" C-m
    tar cfv $SIMPLE_BK_NAME $BK_FILE
    sleep 10
    tmux send-keys -t $SESSION_NAME:0 "save-on" C-m
    echo "minecraft_server backup compleate!"
    gzip -f $SIMPLE_BK_NAME
    find $BK_DIR -name "mc_simple_backup_*.tar.gz" -type f -mtime +$BK_GEN -exec rm {} \;
  else
    echo "Backup start ..."
    gzip -f $HOUR_BK_NAME
    find $BK_DIR -name "mc_simple_backup_*.tar.gz" -type f -mtime +$BK_GEN -exec rm {} \;
  fi
}

# Minecraft 完全バックアップ処理
f_backup() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null; then
    echo "Full backup start minecraft data..."
    tmux send-keys -t $SESSION_NAME:0 "say SERVER SHUTTING DOWN IN 10 SECONDS. Saving map..." C-m
    sleep 10
    tmux send-keys -t $SESSION_NAME:0 "save-all" C-m
    tmux send-keys -t $SESSION_NAME:0 "stop" C-m
    while :
      do
        if
          pgrep -u $USERNAME -f $SERVICE > /dev/null; then
          echo "Stopping $SERVICE"
          sleep 10
        else
          echo "Stopped minecraft_server"
          echo "Full Backup start ..."
          tar cfvz $FULL_BK_NAME $MC_PATH
          echo "Full Backup compleate!"
          find $BK_DIR -name "mc_full_backup_*.tar.gz" -type f -mtime +$BK_GEN -exec rm {} \;
          break
        fi
      done
    echo "Starting $SERVICE..."
    tmux send-keys -t $SESSION_NAME:0 "java -Xmx$XMX -Xms$XMS -jar $SERVICE nogui" C-m
  else
    echo "Full Backup start ..."
    tar cfvz $FULL_BK_NAME $MC_PATH
    echo "Full Backup compleate!"
    find $BK_DIR -name "mc_full_backup_*.tar.gz" -type f -mtime +$BK_GEN -exec rm {} \;
  fi
}

# Minecraft 起動状態確認処理
status() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null; then
    echo "$SERVICE is already running!"
    exit
  else
    echo "$SERVICE is not running!"
    exit
  fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  s_backup)
    s_backup
    ;;
  f_backup)
    f_backup
    ;;
  status)
    status
    ;;
  *)
    echo  $"Usage: $0 {start|stop|s_backup|f_backup|status}"
esac
