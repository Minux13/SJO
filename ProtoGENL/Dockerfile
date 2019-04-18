FROM ubuntu:bionic
MAINTAINER miriam.physics@gmail.com


# getting last software catalog, upgrade and install java
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y  software-properties-common && \
    apt-get update --fix-missing
RUN apt-get install -y openjdk-8-jre-headless maven tomcat9

RUN mkdir -p /app

WORKDIR /app

COPY . /app

EXPOSE 80

