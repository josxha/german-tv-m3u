import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'm3u_service.dart';

Future<void> main(List<String> args) async {

  final router = Router();
  router.get('/', (Request req) async {
    final responseString = M3uService.getFilteredString();
    return Response.ok(responseString, headers: {
      HttpHeaders.contentTypeHeader: "text/plain"
    });
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  final ip = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
