# minecraft-server-docker
For start MINECRAFT in docker:
## Install `docker` and `docker-compose`:
```sudo apt install docker -y && sudo apt install docker-compose -y && sudo apt install make -y```
## Give some user permission for use docker:
```newgrp docker; sudo usermod -aG docker $USER; docker ps```
## Download repo and go inside:
```git clone https://github.com/NettyW/minecraft-server-docker.git && cd minecraft-server-docker```
## Start minecraft server:
```./minecraft-server.sh start```
## Manage your server:
```./minecraft-server.sh save|restart|stop|start|rebuild```