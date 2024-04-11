#!/bin/bash

mkdir -p /opt/android-sdk-linux/bin/
cp /opt/tools/android-env.sh /opt/android-sdk-linux/bin/
source /opt/android-sdk-linux/bin/android-env.sh

echo "Using Built-In SDK Flavour"

cd ${ANDROID_HOME}
echo "Set ANDROID_HOME to ${ANDROID_HOME}"

if [ -f .bootstrapped ]
then
    echo "SDK Tools already bootstrapped. Skipping initial setup"
else
    echo "Bootstrapping SDK-Tools"
    mkdir -p cmdline-tools/latest/ \
      && curl -sSL http://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -o sdk-tools-linux.zip \
      && bsdtar xvf sdk-tools-linux.zip --strip-components=1 -C cmdline-tools/latest \
      && rm sdk-tools-linux.zip \
      && touch .bootstrapped
fi

echo "Make sure repositories.cfg exists"
mkdir -p ~/.android/
touch ~/.android/repositories.cfg

echo "Copying Licences"
cp -rv /opt/licenses ${ANDROID_HOME}/licenses

echo "Copying Tools"
mkdir -p ${ANDROID_HOME}/bin
cp -v /opt/tools/*.sh ${ANDROID_HOME}/bin

echo "Print sdkmanager version"
sdkmanager --version


echo "Installing packages"

while read p; do
  android-accept-licenses.sh "sdkmanager ${SDKMNGR_OPTS} ${p}"
done < /opt/tools/package-list.txt


echo "Updating SDK"
update_sdk

echo "Accepting Licenses"
android-accept-licenses.sh "sdkmanager ${SDKMNGR_OPTS} --licenses"

# https://stackoverflow.com/questions/35128229/error-no-toolchains-found-in-the-ndk-toolchains-folder-for-abi-with-prefix-llv
if [ -d /opt/android-sdk-linux/ndk-bundle/toolchains ]
then
    ( cd /opt/android-sdk-linux/ndk-bundle/toolchains \
    && ln -sf aarch64-linux-android-4.9 mips64el-linux-android \
    && ln -sf arm-linux-androideabi-4.9 mipsel-linux-android )
fi
