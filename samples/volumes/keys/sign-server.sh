#!/bin/sh

#-------------------------------------------------------------------------------
# Copyright (c) 2023 Primos TI
# sign-server.sh
#
# Licensed under the MIT License. See LICENSE in the project root for license
# information.
#-------------------------------------------------------------------------------
# Issue the "Sample Server" certificate.
#-------------------------------------------------------------------------------

set -e

basepath=$(dirname $0)

cd $basepath

openssl req -new -key server.key -out server.csr -config server.conf
openssl x509 -req -days 36500 -in server.csr -CA ca.cer -CAkey ca.key -CAcreateserial -out server.cer -extfile server.conf -extensions v3_ca
openssl verify -CAfile ca.cer server.cer
openssl x509 -in server.cer -noout -text
