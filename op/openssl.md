# OpenSSL

## Self Signed Certificate

### Prepare

```bash
mkdir -p CA/{certs,crl,newcerts,private}
touch CA/index.txt
echo 00 > CA/serial
```

### CA cert and key

```bash
openssl req -new -x509 -days 3650 -keyout ca.key -out ca.crt -config openssl.cnf
```

### Server cert and key

```bash
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -config openssl.cnf
openssl ca -in server.csr -out server.crt -cert ca.crt -keyfile ca.key -config openssl.cnf -days 3650
```

## Multiple Domian name Certificate

Configure `openssl.cnf`:

- Origin

  ```ini
  commonName      = Common Name (eg, your name or your server\'s hostname)
  commonName_max  = 64
  ```

- Multiple Domain

  ```ini
  0.commonName     = <Common Name 0>
  0.commonName_max = 64
  1.commonName     = <Common Name 1>
  1.commonName_max = 64
  ...
  N.commonName     = <Common Name N>
  N.commonName_max = 64
  ```
