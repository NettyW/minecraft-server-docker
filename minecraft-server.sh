#!/bin/bash
#docker exec -i rcon-minecraft ./rcon -a 172.30.0.2:25575 -p 1234 command
RCON_PASSWORD="1234"
RCON_PORT="25575"
CONTAINER_NAME_MC="minecraft-server-1.21.4"
CONTAINER_NAME_RCON="rcon-minecraft"

MC_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME_MC)

function save_world {
  docker exec -i $CONTAINER_NAME_RCON ./rcon -a $MC_IP:$RCON_PORT -p $RCON_PASSWORD save-all
}

function restart_server {
  docker exec -i $CONTAINER_NAME_RCON ./rcon -a $MC_IP:$RCON_PORT -p $RCON_PASSWORD stop
  sleep 30
  docker-compose restart
}

function stop_server {
  docker exec -i $CONTAINER_NAME_RCON ./rcon -a $MC_IP:$RCON_PORT -p $RCON_PASSWORD stop
  sleep 30
  docker-compose stop
}

function start_server {
  docker-compose up -d
}

function rebuild_server {
  sudo rm -rf minecraft-data/world && docker-compose up --build -d
}

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
  *)
    echo "Usage: $0 {save|restart|stop|start|rebuild}"
    exit 1
    ;;
esac
