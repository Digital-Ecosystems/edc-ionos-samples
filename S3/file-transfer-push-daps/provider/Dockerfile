# -buster is required to have apt available
FROM openjdk:17-slim-buster

# by default curl is not available, so install it
RUN apt update && apt install curl -y

WORKDIR /app

# Copy jar
COPY ./build/libs/dataspace-connector.jar /app

ENTRYPOINT java -jar dataspace-connector.jar