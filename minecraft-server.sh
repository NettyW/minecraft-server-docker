#!/bin/bash
RCON_PASSWORD="1234"
RCON_PORT="25575"
SERVER_PORT="25565"
CONTAINER_NAME_MC="minecraft-server-1.21.4"
CONTAINER_NAME_RCON="rcon-minecraft"

MC_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME_MC)

function save_world {
  echo "Saving the game (this may take a moment!)"
  docker exec -i $CONTAINER_NAME_RCON ./rcon -a ${MC_IP}:${RCON_PORT} -p ${RCON_PASSWORD} save-all
  rc=$?
  if [ $rc -eq 0 ]; then
    echo "Game saved successfully."
  else
    echo "Error: Save command failed with code $rc."
  fi
  echo ""
}

function restart_server {
  echo "Stopping server..."
  docker exec -i $CONTAINER_NAME_RCON ./rcon -a ${MC_IP}:${RCON_PORT} -p ${RCON_PASSWORD} stop
  rc_stop=$?
  if [ $rc_stop -ne 0 ]; then
    echo "Error: Stop command failed with code $rc_stop."
  else
    echo "Server stop command executed successfully."
  fi
  sleep 5
  echo "Restarting containers with docker-compose..."
  docker-compose restart
  rc_restart=$?
  if [ $rc_restart -ne 0 ]; then
    echo "Error: docker-compose restart failed with code $rc_restart."
  else
    echo "Server restarted successfully."
    sleep 2
    info
  fi
  echo ""
}

function stop_server {
  echo "Stopping server..."
  docker exec -i $CONTAINER_NAME_RCON ./rcon -a ${MC_IP}:${RCON_PORT} -p ${RCON_PASSWORD} stop
  rc_stop=$?
  if [ $rc_stop -ne 0 ]; then
    echo "Error: Stop command failed with code $rc_stop."
  else
    echo "Server stop command executed successfully."
  fi
  sleep 5
  echo "Stopping containers with docker-compose..."
  docker-compose stop
  rc_dc=$?
  if [ $rc_dc -ne 0 ]; then
    echo "Error: docker-compose stop failed with code $rc_dc."
  else
    echo "Containers stopped successfully."
  fi
  echo ""
}

function start_server {
  echo "Starting containers with docker-compose..."
  docker-compose up -d
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "Error: docker-compose up failed with code $rc."
  else
    echo "Containers started successfully."
    sleep 2
    info
  fi
  echo ""
}

function rebuild_server {
  echo "Removing world data and rebuilding containers..."
  sudo rm -rf minecraft-data/world && docker-compose up --build -d
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "Error: Rebuild failed with code $rc."
  else
    echo "Server rebuilt successfully."
    sleep 2
    info
  fi
  echo ""
}

function cron_on {
  SCRIPT_PATH=$(realpath "$0")
  CRON_JOB="*/15 * * * * ${SCRIPT_PATH} save"
  (crontab -l 2>/dev/null | grep -v -F "${SCRIPT_PATH} save"; echo "$CRON_JOB") | crontab -
  echo "Cron job added for auto save every 15 minutes."
  echo ""
}

function cron_off {
  SCRIPT_PATH=$(realpath "$0")
  (crontab -l 2>/dev/null | grep -v -F "${SCRIPT_PATH} save") | crontab -
  echo "Cron job for auto save removed."
  echo ""
}

function send_command {
  if [ $# -eq 0 ]; then
    echo "Usage: $0 command <rcon_command>"
    exit 1
  fi
  CMD="$*"
  echo "==================== Sending Command ===================="
  echo "Command: $CMD"
  echo "---------------------------------------------------------"
  OUTPUT=$(docker exec -i $CONTAINER_NAME_RCON ./rcon -a ${MC_IP}:${RCON_PORT} -p ${RCON_PASSWORD} "$CMD")
  RC=$?
  if [ $RC -eq 0 ]; then
    echo "Command executed successfully."
    echo "Output: $OUTPUT"
  else
    echo "Error: Command execution failed with code $RC."
  fi
  echo "========================================================="
  echo ""
}

function info {
  echo "==================== Server Info ===================="
  echo "Server IP: $MC_IP:$SERVER_PORT"
  echo -n "Online Players: "
  players_output=$(docker exec -i $CONTAINER_NAME_RCON ./rcon -a ${MC_IP}:${RCON_PORT} -p ${RCON_PASSWORD} list)
  players=$(echo "$players_output" | awk '{print $3}')
  if [ -z "$players" ]; then
    echo "N/A (unable to retrieve)"
  else
    echo "$players"
  fi
  echo -n "World Size: "
  world_size=$(du -sh ./minecraft-data/world 2>/dev/null | awk '{print $1}')
  if [ -z "$world_size" ]; then
    echo "N/A"
  else
    echo "$world_size"
  fi
  echo "---------------- Cron Info ----------------"
  SCRIPT_PATH=$(realpath "$0")
  cron_exists=$(crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH" | grep -F "save")
  if [ -z "$cron_exists" ]; then
    echo "Cron job for auto save: Not enabled."
  else
    echo "Cron job for auto save: Enabled."
  fi
  LAST_SAVE=$(grep "\[Rcon: Saved the game\]" minecraft-data/logs/latest.log | tail -n 1)
  if [ -n "$LAST_SAVE" ]; then
    LAST_SAVE_TIME=$(echo "$LAST_SAVE" | sed -n 's/^\[\([^]]*\)\].*/\1/p')
    echo "Last Save: $LAST_SAVE_TIME"
  else
    echo "Last Save: Never"
  fi
  echo "===================================================="
  echo ""
}

function help {
  echo "Usage: $0 {save|restart|stop|start|rebuild|cron_on|cron_off|info|command|help}"
  echo " save      - Save the game world"
  echo " restart   - Stop the server and restart containers"
  echo " stop      - Stop the server and containers"
  echo " start     - Start the containers"
  echo " rebuild   - Rebuild the server (remove world data)"
  echo " cron_on   - Enable auto-save cron job (every 15 minutes)"
  echo " cron_off  - Disable auto-save cron job"
  echo " info      - Show server info and cron status, including last save time from logs"
  echo " command   - Send an rcon command. Usage: $0 command \"rcon_command\""
  echo " help      - Show this help message"
  echo ""
}

if [ -z "$1" ]; then
  info
  help
  exit 0
fi

case "$1" in
  save)
    save_world
    ;;
  restart)
    restart_server
    ;;
  stop)
    stop_server
    ;;
  start)
    start_server
    ;;
  rebuild)
    rebuild_server
    ;;
  cron_on)
    cron_on
    ;;
  cron_off)
    cron_off
    ;;
  info)
    info
    ;;
  command)
    shift
    send_command "$@"
    ;;
  help)
    help
    ;;
  *)
    echo "Usage: $0 {save|restart|stop|start|rebuild|cron_on|cron_off|info|command|help}"
    exit 1
    ;;
esac
