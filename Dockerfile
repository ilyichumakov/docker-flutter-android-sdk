FROM ubuntu:22.04

# See all Flutter versions here - https://docs.flutter.dev/development/tools/sdk/releases
ARG flutter_version=3.16.5
# See all Dart versions here - https://dart.dev/get-dart/archive
# Choose `download debian package` for see correct version
ARG dart_version=3.2.3

ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux
ENV PATH $PATH:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/bin:~/.pub-cache/bin:/opt/flutter/bin
ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386
# Install Required Tools
RUN apt-get update -yqq
RUN apt-get install -y \
  curl \
  expect \
  git \
  gnupg2 \
  build-essential \
  make \
  openjdk-17-jdk \
  wget \
  unzip \
  vim \
  openssh-client \
  locales \
  ca-certificates\
  libarchive-tools \
  software-properties-common \
  && update-ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.UTF-8

# Create android User
RUN groupadd android && useradd -d /opt/android-sdk-linux -g android -u 1000 android

# Copy Tools
COPY tools /opt/tools

# Copy Licenses
COPY licenses /opt/licenses

RUN cd /opt/ && wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$flutter_version-stable.tar.xz && \
    tar xf flutter_linux_$flutter_version-stable.tar.xz && \
    rm -rf flutter_linux_$flutter_version-stable.tar.xz

RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | tee /etc/apt/sources.list.d/dart_stable.list && \
    apt-get update && apt-get install -y dart=$dart_version-1

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales

# Working Directory
WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in

RUN echo 'no' | avdmanager -v create avd --name avd34 --tag google_apis --package "system-images;android-34;google_apis;x86_64"
