FROM dart:stable as build

WORKDIR /app
COPY . .

RUN dart pub get
RUN dart compile exe bin/server.dart

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server.exe /app/server

ENTRYPOINT ["/app/server"]