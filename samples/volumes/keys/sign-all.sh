#!/bin/sh

#-------------------------------------------------------------------------------
# Copyright (c) 2023 Primos TI
# sign-all.sh
#
# Licensed under the MIT License. See LICENSE in the project root for license
# information.
#-------------------------------------------------------------------------------
# Sign all certificates.
#-------------------------------------------------------------------------------

set -e

basepath=$(dirname $0)

cd $basepath

./sign-ca.sh && echo ""
./sign-client.sh && echo ""
./sign-server.sh
