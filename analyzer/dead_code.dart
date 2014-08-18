library dead_code;

/*

Running the file will print:

---------------- number of methods ----------------
all         dead        %
5034        4467        89

----------------------- size ----------------------
all         dead        %
2097229     1543402     74


It shows that 89% of the methods have not been called, and they account for 74% of the file size.
*/

import 'common.dart';
import 'package:fp/fp.dart' as _;

main() {
  final d = deadCode(new Dump("../app/build/web/sample_app.dart.js.info.json"),
      new Tracing("../chrome_logs/chrome_debug.log"));

  printDeadCode(d);
}

void printDeadCode(Map m) {
  print("---------------- number of methods ----------------");
  printRow(["all", "dead", "%"], [12, 12, 5]);
  printRow([m["allLength"], m["deadLength"], m["percentLength"]], [12, 12, 5]);

  print("");
  print("----------------------- size ----------------------");
  printRow(["all", "dead", "%"], [12, 12, 5]);
  printRow([m["allSize"], m["deadSize"], m["percentSize"]], [12, 12, 5]);
}

Map deadCode(Dump a, Tracing t) {
  final allFuncsInDump = a.allFunctionsInDump;
  final allLength = allFuncsInDump.length;
  final allSize = a.reduceSize(allFuncsInDump.map(_.getField("info")));

  final dead = subLists(a.allFunctionsInDump, t.calls);
  final deadLength = dead.length;
  final deadSize = a.reduceSize(dead.map(_.getField("info")));

  final percentLength = ((deadLength / allLength) * 100).round();
  final percentSize = ((deadSize / allSize) * 100).round();

  return {
    "deadLength" : deadLength,
    "deadSize" : deadSize,

    "allLength" : allLength,
    "allSize" : allSize,

    "percentLength" : percentLength,
    "percentSize" : percentSize
  };
}