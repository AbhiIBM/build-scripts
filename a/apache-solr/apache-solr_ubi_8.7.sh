#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package          : solr
# Version          : releases/solr/9.3.0
# Source repo      : https://github.com/apache/solr
# Tested on        : UBI 8.7
# Language         : Java
# Travis-Check     : True 
# Script License   : Apache License, Version 2 or later
# Maintainer       : Abhishek Dwivedi <Abhishek.Dwivedi6@ibm.com>
#
# Disclaimer       : This script has been tested in root mode on given
# ==========         platform using the mentioned version of the package.
#                    It may not work as expected with newer versions of the
#                    package and/or distribution. In such case, please
#                    contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=solr
PACKAGE_VERSION=${1:-releases/solr/9.3.0}
PACKAGE_URL=https://github.com/apache/solr
HOME_DIR=${PWD}

# Install dependencies
yum install -y wget git java-11-openjdk java-11-openjdk-devel python39-devel.ppc64le

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$HOME_DIR/bin/:$PATH

# Clone solr repo
cd $HOME_DIR
git clone $PACKAGE_URL
cd  $PACKAGE_NAME
git checkout $PACKAGE_VERSION

chmod +x gradlew
./gradlew localSettings

sed 's/tests.heapsize=512m/tests.heapsize=1024m/g' gradle.properties
sed 's/tests.minheapsize=512m/tests.minheapsize=1024m/g' gradle.properties
sed '71 s/Xmx1g/Xmx2g/'	gradle.properties

if ! ./gradlew check -x test -Ptask.times=true -Pvalidation.errorprone=true -Dorg.gradle.jvmargs=-Xmx4g ; then
    echo "------------------$PACKAGE_NAME:install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

#./gradlew localSettings
# sed 's/tests.heapsize=512m/tests.heapsize=1024m/g' gradle.properties
# sed 's/tests.minheapsize=512m/tests.minheapsize=1024m/g' gradle.properties
# sed '71 s/Xmx1g/Xmx2g/'	gradle.properties
#./gradlew test -x solr:modules:s3-repository

if ! ./gradlew test -Dtests.heap.size=4096m -Dorg.gradle.jvmargs=-Xmx4g ; then
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

