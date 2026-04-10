FROM alpine:latest AS downloader
ARG DOWNLOAD_SERVER_URL=https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar
WORKDIR /tmp
RUN apk add --no-cache wget \
    && wget -O minecraft_server.jar "${DOWNLOAD_SERVER_URL}"

FROM eclipse-temurin:21-jdk-jammy
ARG MINECRAFT_VERSION=1.20.4
ARG EULA=TRUE
ARG SERVER_PORT=25565
ENV MINECRAFT_VERSION=${MINECRAFT_VERSION}
ENV EULA=${EULA}
USER root
VOLUME /data
WORKDIR /data
COPY --from=downloader /tmp/minecraft_server.jar /
EXPOSE ${SERVER_PORT}
CMD bash -c "echo 'eula=${EULA}' > eula.txt && java -Xms1G -Xmx3G -jar /minecraft_server.jar nogui"
