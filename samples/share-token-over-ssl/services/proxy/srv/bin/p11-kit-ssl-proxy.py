#!/usr/bin/python
# -*- coding: utf-8 -*-

#-------------------------------------------------------------------------------
# Copyright (c) 2023 Primos TI
# p11-kit-ssl-proxy.py
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
# This script is an alternative to the p11-kit-ssl-proxy.sh script.
#
# See https://github.com/PrimosTI/softhsm2 for more information.
#-------------------------------------------------------------------------------

import socket
import ssl
import threading
import hashlib
import sys

PROXY_PORT = 12345
"""The port on which the proxy listens for connections."""
PROXY_SOCKET = '/srv/run/sockets/token1.sock'
"""The path to the P11-KIT socket."""

SSL_CERT_FILE = '/srv/keys/server.cer'
"""The path to the certificate file."""
SSL_KEY_FILE = '/srv/keys/server.key'
"""The path to the key file."""
SSL_CA_FILE = '/srv/keys/ca.cer'
"""The path to the CA file."""

BUFFER_SIZE = 1024
"""The size of the buffer used to transfer data between sockets."""

#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
def main():
  """This is the main entry point of the program."""

  # SSL/TLS configuration
  ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
  ctx.verify_mode = ssl.CERT_REQUIRED
  ctx.load_cert_chain(SSL_CERT_FILE, SSL_KEY_FILE)
  ctx.load_verify_locations(SSL_CA_FILE)

  # Create a socket to listen for connections
  with socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0) as sock:
    sock.bind(('0.0.0.0', PROXY_PORT))
    sock.listen(5)

    with ctx.wrap_socket(sock, server_side=True) as ssl_sock:
      accept_connections(ssl_sock)

#-------------------------------------------------------------------------------
# listen
#-------------------------------------------------------------------------------
def accept_connections(ssl_sock: ssl.SSLSocket):
  """This function listens for connections on the given socket."""

  # Loop for accepting multiple connections
  while True:
    try:
      # Accept a connection
      client_sock, addr = ssl_sock.accept()

      # Get the client certificate
      client_cert_raw = client_sock.getpeercert(binary_form=True)
      fingerprint = hashlib.sha1(client_cert_raw).hexdigest()

      print('Connection from:', addr, "with cert:", fingerprint)

      # HINT: At this point, you can use load and verify the client certificate
      #       for custom authentication purposes.

      # HINT: At this point, you can identify the client by certificate to apply
      #       custom ACL's and select the correct p11-kit socket to connect to.

      # Connect to the p11-kit socket
      p11_sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
      p11_sock.connect(PROXY_SOCKET)

      # Pipe data between the client socket and the p11-kit socket
      socket_pipe(client_sock, p11_sock)

    except Exception as e:
      print('Error:', e, file=sys.stderr)

#-------------------------------------------------------------------------------
# socket_pipe
#-------------------------------------------------------------------------------
def socket_pipe(socket1: socket.socket, socket2: socket.socket):
  """This function pipes data between two sockets."""

  def pipe(sock1: socket.socket, sock2: socket.socket):
    while True:
      data = sock1.recv(BUFFER_SIZE)
      if not data:
        # If the socket is closed, exit the loop
        sock2.shutdown(socket.SHUT_WR)
        return

      sock2.sendall(data)

  threading.Thread(target=pipe, args=(socket1, socket2)).start()
  threading.Thread(target=pipe, args=(socket2, socket1)).start()

#-------------------------------------------------------------------------------
# Call the main entry point of the program.
# It is executed when the program is run from the command line.
# It is not executed when the program is imported as a module.
#-------------------------------------------------------------------------------
if __name__ == '__main__':
  try:
    main()
  except KeyboardInterrupt:
    print('Exiting...', file=sys.stderr)
    exit(0)
  except Exception as e:
    print('Error:', e, file=sys.stderr)
    exit(1)
