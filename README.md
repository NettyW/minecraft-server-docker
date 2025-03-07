# minecraft-server-docker
For start MINECRAFT in docker:
1. Install `docker` and `docker-compose`:
```sudo apt install docker -y && sudo apt install docker-compose -y && sudo apt install make -y```
2. Give some user permission for use docker:
```newgrp docker; sudo usermod -aG docker $USER; docker ps```
3. Start minecraft server:
```./minecraft-server.sh save|restart|stop|start|rebuild```