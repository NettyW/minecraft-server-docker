FROM alpine:latest AS downloader
ARG DOWNLOAD_SERVER_URL=https://piston-data.mojang.com/v1/objects/64bb6d763bed0a9f1d632ec347938594144943ed/server.jar
WORKDIR /tmp
RUN apk add --no-cache wget \
    && wget -O minecraft_server.jar "${DOWNLOAD_SERVER_URL}"

FROM eclipse-temurin:21-jdk-jammy
ARG MINECRAFT_VERSION=1.21.11
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
