# Sharing tokens to another containers on the same host

Sometimes may be useful to share the token remotely. This can be done exposing the token via a [Unix Domain Socket] by
running `p11-kit server` command on the `ghcr.io/primosti/softhsm2` container. Then, the token can be accessed by using
the PKCS #11 module `p11-kit-client.so` to connect to this socket on the client side.

This is useful, for example, to protect a key material available to other containers applications, maintaining these
materials isolated and protected from the other environments. As example, consider the following scenarios:

- Connect to a SSH server using a key material;
- Stablish a mutual TLS connection using a key material;
- Store certificates and keys available to applications running on other containers;

Normally, on this scenarios, when a key material is needed, these keys are stored in a file (encrypted by a password, I
hope) and the application accesses the file to read the key material (with the password). This is not safe, because the
key material can be exposed, if the application is compromised. With a PKCS #11 token, the key material access is
protected by a PIN, and the application can only operate with the key material, not reading it.

The following diagram shows the scenario:

![share-token-diagram]

## Security considerations

**Warning:** Sharing the token remotely can have security implications. Take security measures to protect the token from
unauthorized access.

Some security measures include:

- Use strong Security Officer (SO) PIN and User PIN to protect the token.
- Define a specific user and group for the container.
- Set the permissions of the exposed socket to be accessible only by a specific user and group.
- When sharing the token over network, use a secure connection with mutual authentication (e.g. TLS).
- Protect the access to the SoftHSMv2 storage. Read more about [SoftHSMv2 storage internals].

> YOU MUST ANALYZE YOUR OWN SCENARIO AND TAKE THE APPROPRIATE SECURITY MEASURES, BY YOUR OWN RISK.

[Unix Domain Socket]: https://man7.org/linux/man-pages/man7/unix.7.html
[SoftHSMv2 storage internals]: https://xakcop.com/post/softhsmv2/
[share-token-diagram]: share-token-to-containers.png "Sharing tokens to another containers on the same host diagram"
