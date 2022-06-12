# ExSpring83
[![Coverage Status](https://coveralls.io/repos/github/davemenninger/exspring83/badge.svg?branch=main)](https://coveralls.io/github/davemenninger/exspring83?branch=main)

This is an attempt to implement the Spring '83 spec designed by Robin Sloan at: [Spring '83](https://github.com/robinsloan/spring-83-spec/blob/main/draft-20220609.md)

Further description of Spring '83 can be found in Robin's newsletter: [Specifying Spring ‘83](https://www.robinsloan.com/lab/specifying-spring-83/)

## Key pairs

To generate a Spring '83 key pair, run `mix spring83.key_gen`

## Server

To run the ExSpring83 server, run `mix spring83.server` (which is an alias for `mix run --no-halt`) and check [http://localhost:4040/](http://localhost:4040/)

## Client

Not implemented.  In the meantime:

```
 curl -v -X PUT \
         -H "Spring-Version: 83" \
         -H "Content-Type: text/html;charset=utf-8" \
         -H "If-Unmodified-Since: Sun, 12 Jun 2022 02:39:31 GMT" \
         -H "Authorization: Spring-83 Signature=E35366E1E4D206DB978E997D471AC52A86F9DC4F28893B6530D04929AD9102A866789C3DBE7F221C88D76CDA4553E57F6E7024608906736EDBF229583F1DBE05" \
         -d '<meta http-equiv="last-modified" content="Sun, 12 Jun 2022 02:39:31 GMT">' \
         http://localhost:4040/132EBED3BEC65A3CEAA6718574AD2EE92A2C83D6FED547807E7DC9492624F31F
           
```
