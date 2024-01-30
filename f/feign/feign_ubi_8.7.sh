#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package       : feign
# Version       : 13.1
# Source repo   : https://github.com/OpenFeign/feign
# Tested on     : UBI 8.7
# Language      : Java
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Abhishek Dwivedi <Abhishek.Dwivedi6@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------
PACKAGE_NAME=feign
PACKAGE_VERSION=${1:-13.1}
PACKAGE_URL=https://github.com/OpenFeign/feign

HOME_DIR=`pwd`

yum install -y git wget gcc-c++ gcc java-11-openjdk java-11-openjdk-devel java-11-openjdk-headless java-1.8.0-openjdk java-1.8.0-openjdk-devel java-1.8.0-openjdk-headless java-17-openjdk java-17-openjdk-devel java-17-openjdk-headless  java-21-openjdk java-21-openjdk-devel java-21-openjdk-headless

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
export PATH=$PATH:$JAVA_HOME

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$PATH:$JAVA_HOME

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$PATH:$JAVA_HOME

export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$PATH:$JAVA_HOME

wget https://archive.apache.org/dist/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz
tar -zxf apache-maven-3.8.7-bin.tar.gz
cp -R apache-maven-3.8.7 /usr/local
ln -s /usr/local/apache-maven-3.8.7/bin/mvn /usr/bin/mvn

git clone $PACKAGE_URL $PACKAGE_NAME
cd  $PACKAGE_NAME
git checkout $PACKAGE_VERSION 

if ! ./mvnw -ntp dependency:resolve-plugins go-offline:resolve-dependencies -DskipTests=true -B ;  then
    echo "------------------$PACKAGE_NAME:install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi


#copying toolchains.xml file to .m2 folder to exceute tests
mkdir ~/.m2
cp /build-scripts/f/feign/toolchains.xml ~/.m2/

if ! ./mvnw -ntp -B verify ; then
    echo "------------------$PACKAGE_NAME:install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi