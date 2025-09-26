FROM alpine:latest AS downloader
ARG DOWNLOAD_SERVER_URL=https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar
WORKDIR /tmp
RUN apk add --no-cache wget \
    && wget -O minecraft_server.jar "${DOWNLOAD_SERVER_URL}"

FROM openjdk:24-slim
ARG MINECRAFT_VERSION=1.21.8
ARG EULA=TRUE
ARG SERVER_PORT=25565
ENV MINECRAFT_VERSION=${MINECRAFT_VERSION}
ENV EULA=${EULA}
USER root
VOLUME /data
WORKDIR /data
COPY --from=downloader /tmp/minecraft_server.jar /
EXPOSE ${SERVER_PORT}
CMD bash -c "echo 'eula=${EULA}' > eula.txt && java -Xms1G -Xmx2G -jar /minecraft_server.jar nogui"
