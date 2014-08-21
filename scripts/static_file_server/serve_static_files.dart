library serve;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart' show VirtualDirectory;

final HOST = "127.0.0.1";
final PORT = 8080;

main(List<String> args) {
  HttpServer.bind(HOST, PORT).then((server){
    final path = args.first;

    if (!new Directory(path).existsSync()) {
      throw "$path does not exist";
    }

    final vDir = new VirtualDirectory(path)
      ..followLinks = true
      ..jailRoot = false;
    server.listen(vDir.serveRequest);
  });
}
