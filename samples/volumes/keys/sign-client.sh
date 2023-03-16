#!/bin/sh

#-------------------------------------------------------------------------------
# Copyright (c) 2023 Primos TI
# sign-client.sh
#
# Licensed under the MIT License. See LICENSE in the project root for license
# information.
#-------------------------------------------------------------------------------
# Issue the "Sample Client" certificate.
#-------------------------------------------------------------------------------

set -e

basepath=$(dirname $0)

cd $basepath

openssl req -new -key client.key -out client.csr -config client.conf
openssl x509 -req -days 36500 -in client.csr -CA ca.cer -CAkey ca.key -CAcreateserial -out client.cer -extfile client.conf -extensions v3_ca
openssl verify -CAfile ca.cer client.cer
openssl x509 -in client.cer -noout -text
