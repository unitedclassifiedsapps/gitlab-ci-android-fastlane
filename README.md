# gitlab-ci-android-fastlane
This Docker image contains the Android SDK and most common packages necessary for building Android apps in a CI tool like GitLab CI (Android SDK, git, fastlane). Make sure your CI environment's caching works as expected, this greatly improves the build time, especially if you use multiple build jobs.

Updated for Android 12 by using Open JDK 11. Also contains a version name updater in Bash

A `.gitlab-ci.yml` with caching of your project's dependencies would look like this:

```
image: ijhdev/gitlab-ci-fastlane-android


variables:
  ANDROID_COMPILE_SDK: "31"
  ANDROID_BUILD_TOOLS: "30.0.3"
  ANDROID_SDK_TOOLS:   "7583922"
  LC_ALL: "en_US.UTF-8"
  LANG: "en_US.UTF-8"
  GIT_STRATEGY: clone
  
before_script:
  - export GRADLE_USER_HOME=$(pwd)/.gradle
  - chmod +x ./gradlew

cache:
  key: ${CI_PROJECT_ID}
  paths:
    - .gradle/
    
tages:
  - unit_test
#  - ui_test
  - debug_build
  - rc_build
  - play_store

unit_test:
  tags:
    - my_build_runner
  dependencies: []
  stage: unit_test
  artifacts:
    paths:
      - fastlane/screenshots
      - fastlane/logs
    expire_in: 1 hour
  script:
    - fastlane tests
    - fastlane simplyBeDebug

debug_build:
  tags:
    - my_build_runner
  dependencies: []
  stage: debug_build
  artifacts:
    paths:
      - app/build/outputs/
    expire_in: 1 week
  script:
    - bash ./version_updater.sh
    - fastlane buildDebug
```
