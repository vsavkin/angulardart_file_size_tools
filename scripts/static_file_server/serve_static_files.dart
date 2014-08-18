library serve;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart' show VirtualDirectory;

final HOST = "127.0.0.1";
final PORT = 8080;

main() {
  HttpServer.bind(HOST, PORT).then((server){
    var root = Platform.script.resolve('./../../app/build/web').toFilePath();
    final vDir = new VirtualDirectory(root)
      ..followLinks = true
      ..jailRoot = false;
    server.listen(vDir.serveRequest);
  });
}
