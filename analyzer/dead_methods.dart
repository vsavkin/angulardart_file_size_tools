library dead_methods;

import 'common.dart';
import 'package:fp/fp.dart' as _;
import 'dart:io';

main(List<String> args) {
  final t = new Tracing("../chrome_logs/chrome_debug.log");
  final d = new Dump("../dumps/dump.json");

  final deadMethods = subLists(d.allFunctionsInDump, t.calls);
  final rows = deadMethods.map(createRow);

  final p = printRows(["Lib", "Class", "Func"], rows);
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