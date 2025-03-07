FROM openjdk:24-slim
ENV MINECRAFT_VERSION=1.21.4
ENV EULA=TRUE
WORKDIR /data
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
RUN wget -O minecraft_server.jar "https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar" && echo "eula=${EULA}" > eula.txt
EXPOSE 25565
VOLUME ["/data/config", "/data/world"]
CMD ["java", "-Xmx2G", "-Xms2G", "-jar", "minecraft_server.jar", "nogui"]
