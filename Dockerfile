FROM alpine:latest AS downloader
ARG DOWNLOAD_SERVER_URL=https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar
WORKDIR /tmp
RUN apk add --no-cache wget
RUN wget -O minecraft_server.jar "${DOWNLOAD_SERVER_URL}"

FROM openjdk:24-slim
ARG MINECRAFT_VERSION=1.21.4
ARG EULA=TRUE
ARG USER=minecraft
ARG SERVER_PORT=25565
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd -g ${USER_GID} ${USER} && \
    useradd -u ${USER_UID} -g ${USER_GID} -m ${USER}
ENV MINECRAFT_VERSION=${MINECRAFT_VERSION}
ENV EULA=${EULA}
WORKDIR /data
COPY --from=downloader /tmp/minecraft_server.jar .
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    echo "eula=${EULA}" > eula.txt
EXPOSE ${SERVER_PORT}
VOLUME ["/data/config", "/data/world"]
USER root
RUN mkdir -p /data/config /data/world && \
    chown -R ${USER_UID}:${USER_GID} /data/config /data/world && \
    chmod -R 755 /data/config /data/world
USER ${USER}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["java", "-Xmx2G", "-Xms2G", "-jar", "minecraft_server.jar", "nogui"]
