FROM ubuntu:17.04
MAINTAINER Peter Turza <peter.turza@gmail.com>

ENV VERSION_SDK_TOOLS "3859397"
ENV VERSION_BUILD_TOOLS "25.0.3"
ENV VERSION_TARGET_SDK "25"

ENV ANDROID_HOME "/sdk"
ENV VERSION_ANDROID_NDK "android-ndk-r15"
ENV ANDROID_NDK_HOME "/sdk/${VERSION_ANDROID_NDK}"

ENV PATH "$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      curl \
      html2text \
      openjdk-8-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      zip \
      git \
      ruby \
      ruby-dev \
      build-essential \
      file \
      ssh \
      libqt5widgets5 \
      libqt5svg5 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

ADD https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip /tools.zip
RUN unzip /tools.zip -d /sdk && \
    rm -v /tools.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

RUN ${ANDROID_HOME}/tools/bin/sdkmanager "tools" "platforms;android-${VERSION_TARGET_SDK}" "build-tools;${VERSION_BUILD_TOOLS}"
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "emulator" "system-images;android-${VERSION_TARGET_SDK};google_apis;armeabi-v7a"

RUN echo no | ${ANDROID_HOME}/tools/bin/avdmanager create avd -f --name test --abi google_apis/armeabi-v7a --package "system-images;android-${VERSION_TARGET_SDK};google_apis;armeabi-v7a"

RUN gem install fastlane

ADD https://dl.google.com/android/repository/${VERSION_ANDROID_NDK}-linux-x86_64.zip /ndk.zip
RUN unzip /ndk.zip -d /sdk && \
    rm -v /ndk.zip

RUN ${ANDROID_HOME}/tools/bin/sdkmanager "cmake;3.6.3155560"