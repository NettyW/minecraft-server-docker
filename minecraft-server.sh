#!/bin/bash
DIVIDER="============================================================"
RCON_PASSWORD="1234"
RCON_PORT="25575"
SERVER_PORT="25565"
CONTAINER_NAME_MC="minecraft-server-1.21.4"
CONTAINER_NAME_RCON="rcon-minecraft"

MC_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME_MC)

function save_world {
  echo "$DIVIDER"
  echo "                   Saving the Game"
  echo "$DIVIDER"
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
  echo "$DIVIDER"
  echo "                 Restarting Server"
  echo "$DIVIDER"
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
  echo "$DIVIDER"
  echo "                  Stopping Server"
  echo "$DIVIDER"
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
  echo "$DIVIDER"
  echo "                  Starting Server"
  echo "$DIVIDER"
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
  echo "$DIVIDER"
  echo "                 Rebuilding Server"
  echo "$DIVIDER"
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
  echo "$DIVIDER"
  echo "          Cron job added for auto save every 15 minutes."
  echo "$DIVIDER"
  echo ""
}

function cron_off {
  SCRIPT_PATH=$(realpath "$0")
  (crontab -l 2>/dev/null | grep -v -F "${SCRIPT_PATH} save") | crontab -
  echo "$DIVIDER"
  echo "           Cron job for auto save removed."
  echo "$DIVIDER"
  echo ""
}

function send_command {
  if [ $# -eq 0 ]; then
    echo "Usage: $0 command <rcon_command>"
    exit 1
  fi
  CMD="$*"
  echo "$DIVIDER"
  echo "                 Sending Command"
  echo "$DIVIDER"
  echo "Command: $CMD"
  OUTPUT=$(docker exec -i $CONTAINER_NAME_RCON ./rcon -a ${MC_IP}:${RCON_PORT} -p ${RCON_PASSWORD} "$CMD")
  RC=$?
  if [ $RC -eq 0 ]; then
    echo "Command executed successfully."
    # Если команда не начинается с /say, показываем её вывод
    if [[ "$CMD" != "/say"* ]]; then
      echo "Output: $OUTPUT"
    fi
  else
    echo "Error: Command execution failed with code $RC."
  fi
  echo "$DIVIDER"
  echo ""
}

function info {
  HOST_IP=$(hostname -I | awk '{print $1}')
  echo "$DIVIDER"
  echo "                   Server Info"
  echo "$DIVIDER"
  echo "Host IP: ${HOST_IP}:${SERVER_PORT}"
  echo "Container IP: ${MC_IP}:${SERVER_PORT}"
  players_output=$(docker exec -i $CONTAINER_NAME_RCON ./rcon -a ${MC_IP}:${RCON_PORT} -p ${RCON_PASSWORD} list)
  players=$(echo "$players_output" | awk '{print $3}')
  if [ -z "$players" ]; then
    players="N/A (unable to retrieve)"
  fi
  echo "Online Players: $players"
  world_size=$(du -sh ./minecraft-data/world 2>/dev/null | awk '{print $1}')
  if [ -z "$world_size" ]; then
    world_size="N/A"
  fi
  echo "World Size: $world_size"
  echo ""
  echo "$DIVIDER"
  echo "                 Game Time Info"
  echo "$DIVIDER"
  GAME_DAY_OUTPUT=$(docker exec -i $CONTAINER_NAME_RCON ./rcon -a ${MC_IP}:${RCON_PORT} -p ${RCON_PASSWORD} "/time query day")
  game_day=$(echo "$GAME_DAY_OUTPUT" | awk '{print $4}')
  if [ -z "$game_day" ]; then
    echo "Could not retrieve game day."
  else
    echo "Minecraft Day: $game_day"
    real_time_minutes=$(( game_day * 20 ))
    real_days=$(( real_time_minutes / 1440 ))
    real_hours=$(( (real_time_minutes % 1440) / 60 ))
    echo "Real Time: ${real_days} days, ${real_hours} hours"
    # Отправляем в чат сервера информацию, не отображая вывод
    send_command "/say Server running for ${real_days} days and ${real_hours} hours in real time (Game Day: $game_day)" > /dev/null 2>&1
  fi
  echo ""
  echo "$DIVIDER"
  echo "                  Cron Info"
  echo "$DIVIDER"
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
  echo "$DIVIDER"
  echo ""
}

function help {
  echo "$DIVIDER"
  echo "                 Help Information"
  echo "$DIVIDER"
  echo "Usage: $0 {save|restart|stop|start|rebuild|cron_on|cron_off|info|command|help}"
  echo " save      - Save the game world"
  echo " restart   - Stop the server and restart containers"
  echo " stop      - Stop the server and containers"
  echo " start     - Start the containers"
  echo " rebuild   - Rebuild the server (remove world data)"
  echo " cron_on   - Enable auto-save cron job (every 15 minutes)"
  echo " cron_off  - Disable auto-save cron job"
  echo " info      - Show server info and cron status, including game time info"
  echo " command   - Send an rcon command. Usage: $0 command \"rcon_command\""
  echo " help      - Show this help message"
  echo "$DIVIDER"
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
