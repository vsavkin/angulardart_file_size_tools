library dead_methods;

import 'common.dart';
import 'package:fp/fp.dart' as _;
import 'dart:io';

main(List<String> args) {
  final t = new Tracing("../chrome_logs/chrome_debug.log");
  final d = new Dump("../dumps/dump.json");

  final deadMethods = deadCode(d.allFunctionsInDump, t.calls);
  List<List> list = _.groupBy(deadMethods, (n) => n.methodName).values.toList();
  list.sort((a,b) => b.length - a.length);

  final pr = rowOutput([20, 7, 10]);
  final rows = list.map((fns) {
    final size = d.reduceSize(fns.map(_.getField("info")));
    return [fns.first.methodName, fns.length, size];
  });

  final p = printRows(["Name", "Count", "Size"], rows);
  if (args.isEmpty) {
    p(print);
  } else {
    final file = new File(args.first);
    file.createSync();
    final ioSink = file.openWrite();
    p(ioSink.writeln);
    ioSink.close();
  }
}

printRows(List headers, List<List> rows){
  return (printer) {
    printer(headers.map(quotes).join(","));
    rows.forEach((row) => printer(row.map(quotes).join(",")));
  };
}

quotes(s) => '"$s"';

List createRow(Func func) {
  return [func.libraryName, func.className, func.methodName];
}