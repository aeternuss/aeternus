# OpenSSL Multiple Domian name Certificate

Configure \`openssl.cnf\`:

- Origin

  ```
  commonName      = Common Name (eg, your name or your server\'s hostname)
  commonName_max  = 64
  ```

- Multiple Domain

  ```
  0.commonName     = <Common Name 0>
  0.commonName_max = 64
  1.commonName     = <Common Name 1>
  1.commonName_max = 64
  ...
  N.commonName     = <Common Name N>
  N.commonName_max = 64
  ```
