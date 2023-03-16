#!/bin/sh

#-------------------------------------------------------------------------------
# Copyright (c) 2023 Primos TI
# p11-kit-ssl-proxy.sh
#
# Licensed under the MIT License. See LICENSE in the project root for license
# information.
#-------------------------------------------------------------------------------
# Starts a SSL/TLS proxy to forward connections to a p11-kit socket over
# network. This script is intended to be used with the p11-kit-ssl-connect.sh
# script.
#
# This script is part of the "Sharing tokens to another host over network"
# example of Virtual PKCS #11 Module SoftHSMv2 by Primos TI project.
#
# See https://github.com/PrimosTI/softhsm2 for more information.
#-------------------------------------------------------------------------------

# The port to listen on.
PROXY_PORT=12345
# The path to the p11-kit socket.
PROXY_SOCKET=/srv/run/sockets/token1.sock

# The path to the certificate file used by the proxy.
SSL_CERT_FILE=/srv/keys/server.cer
# The path to the key file used by the proxy.
SSL_KEY_FILE=/srv/keys/server.key
# The path to the CA file used by the proxy to verify the client certificate.
SSL_CA_FILE=/srv/keys/ca.cer

# socat server connection arguments.
# OPENSSL-LISTEN: Listens on tcp port. When a connection is accepted, this address behaves as SSL/TLS server.
LISTEN_ARGS=OPENSSL-LISTEN:${PROXY_PORT},cert=${SSL_CERT_FILE},key=${SSL_KEY_FILE},cafile=${SSL_CA_FILE},fork,reuseaddr,verify=1
# socat target to p11-kit socket.
# UNIX: Connects to a UNIX domain socket.
TARGET_ARGS=UNIX:${PROXY_SOCKET}

# Run socat to listen on the proxy port and forward to the p11-kit socket.
# See https://www.mankier.com/1/socat for more information.
exec socat "${LISTEN_ARGS}" "${TARGET_ARGS}"
