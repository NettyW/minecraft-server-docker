FROM alpine:latest AS downloader
ARG DOWNLOAD_SERVER_URL=https://piston-data.mojang.com/v1/objects/11e54c2081420a4d49db3007e66c80a22579ff2a/server.jar
WORKDIR /tmp
RUN apk add --no-cache wget \
    && wget -O minecraft_server.jar "${DOWNLOAD_SERVER_URL}"

FROM openjdk:24-slim
ARG MINECRAFT_VERSION=1.21.9
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
