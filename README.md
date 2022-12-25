# m3u-germany-tv
This project uses the German free tv list from [jnk22/kodinerds-iptv](https://github.com/jnk22/kodinerds-iptv), removes channels with poor quality (e.g. teleshopping) and duplicate content (e.g. regional senders sending the same content) and serves the m3u file as a webserver.

## Running with the Dart SDK

You can run it locally like this:

```
$ dart run bin/server.dart
Server listening on port 8080
```

## Running with Docker

If you have [Docker Desktop](https://www.docker.com/get-started) installed, you
can build and run with the `docker` command:

```
$ docker build . -t m3u-german-tv
$ docker run -it -p 8080:8080 m3u-german-tv
Server listening on port 8080
```