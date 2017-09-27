FROM anapsix/alpine-java:8_jdk
MAINTAINER Peter Turza <peter.turza@gmail.com>

ENV VERSION_SDK_TOOLS "3859397"
ENV VERSION_BUILD_TOOLS "26.0.1"
ENV VERSION_TARGET_SDK "26"

ENV ANDROID_HOME "/sdk"

ENV PATH "$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive


RUN apk update && apk add --no-cache \
    bash \
    perl \
    curl \
    unzip \
    zip \
    git \
    ruby \
    ruby-dev \
    ruby-rdoc \
    ruby-irb \
    openssh \
    g++ \
    make \
    && rm -rf /tmp/* /var/tmp/*

ADD https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip /tools.zip
RUN unzip /tools.zip -d /sdk && \
    rm -v /tools.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

RUN ${ANDROID_HOME}/tools/bin/sdkmanager "tools" "platforms;android-${VERSION_TARGET_SDK}" "build-tools;${VERSION_BUILD_TOOLS}"
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"

RUN gem install fastlane

RUN ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
RUN adb keygen ~/.android/adbkey