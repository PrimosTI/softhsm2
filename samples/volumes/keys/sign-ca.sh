#!/bin/sh

#-------------------------------------------------------------------------------
# Copyright (c) 2023 Primos TI
# sign-ca.sh
#
# Licensed under the MIT License. See LICENSE in the project root for license
# information.
#-------------------------------------------------------------------------------
# Creates the self-signed "Sample Root Certificate Authority - CA" certificate.
#-------------------------------------------------------------------------------

set -e

basepath=$(dirname $0)

cd $basepath

openssl req -x509 -days 36500 -key ca.key -out ca.cer -config ca.conf
openssl verify -CAfile ca.cer ca.cer
openssl x509 -in ca.cer -noout -text
