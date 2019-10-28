# OpenSSL Self Signed Certificate

Prepare
=======

``` {.sourceCode .bash}
mkdir -p CA/{certs,crl,newcerts,private}
touch CA/index.txt
echo 00 > CA/serial
```

CA cert and key
===============

``` {.sourceCode .bash}
openssl req -new -x509 -days 3650 -keyout ca.key -out ca.crt -config openssl.cnf
```

Server cert and key
===================

Key
---

``` {.sourceCode .bash}
openssl genrsa -out server.key 2048
```

Cert request
------------

``` {.sourceCode .bash}
openssl req -new -key server.key -out server.csr -config openssl.cnf
```

Cert
----

``` {.sourceCode .bash}
openssl ca -in server.csr -out server.crt -cert ca.crt -keyfile ca.key -config openssl.cnf -days 3650
```
