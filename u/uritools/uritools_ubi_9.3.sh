#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package       : uritools
# Version       : v4.0.2
# Source repo   : https://github.com/tkem/uritools/
# Tested on     : UBI:9.3
# Language      : Python
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Shubham Garud <Shubham.Garud@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=uritools
PACKAGE_VERSION=${1:-v4.0.2}
PACKAGE_URL=https://github.com/tkem/uritools/

yum install -y git gcc gcc-c++ make wget sudo sqlite-devel.ppc64le

#installation of python3.10
yum install -y openssl-devel bzip2-devel libffi-devel wget xz zlib-devel
wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tar.xz
tar xf Python-3.10.0.tar.xz
cd Python-3.10.0
./configure --prefix=/usr/local --enable-optimizations
make -j4
make install
python3.10 --version
cd ..

pip3 install pytest tox coverage
PATH=$PATH:/usr/local/bin/


# Clone the repository
git clone $PACKAGE_URL $PACKAGE_NAME
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

if !(python3 setup.py install) ; then
    echo "------------------$PACKAGE_NAME:build_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Build_Fails"
    exit 1
fi

# Run test cases
if !(tox); then
    echo "------------------$PACKAGE_NAME:build_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Build_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:build_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Build_and_Test_Success"
    exit 0
fi

