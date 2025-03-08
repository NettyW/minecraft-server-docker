# minecraft-server-docker
For start MINECRAFT in docker:
## Install `docker` and `docker-compose`:
```sudo apt install docker -y && sudo apt install docker-compose -y && sudo apt install make -y```
## Give some user permission for use docker:
```newgrp docker; sudo usermod -aG docker $USER; docker ps```
## Download repo and go inside:
```git clone https://github.com/NettyW/minecraft-server-docker.git && cd minecraft-server-docker && chmod +x minecraft-server.sh```
## Start minecraft server:
```./minecraft-server.sh start```
## Manage your server:
```./minecraft-server.sh save|restart|stop|start|rebuild|cron_on|cron_off|info|command|help```

# Example of usage:
```
nettyw@raspberrypi:~/minecraft-server-docker$ ./minecraft-server.sh info
==================== Server Info ====================
Server IP: 172.30.0.2:25565
Online Players: 2
World Size: 262M
---------------- Cron Info ----------------
Cron job for auto save: Enabled.
Last Save: 22:54:15
====================================================

nettyw@raspberrypi:~/minecraft-server-docker$ ./minecraft-server.sh help
Usage: ./minecraft-server.sh {save|restart|stop|start|rebuild|cron_on|cron_off|info|command|help}
 save      - Save the game world
 restart   - Stop the server and restart containers
 stop      - Stop the server and containers
 start     - Start the containers
 rebuild   - Rebuild the server (remove world data)
 cron_on   - Enable auto-save cron job (every 15 minutes)
 cron_off  - Disable auto-save cron job
 info      - Show server info and cron status, including last save time from logs
 command   - Send an rcon command. Usage: ./minecraft-server.sh command "rcon_command"
 help      - Show this help message
```