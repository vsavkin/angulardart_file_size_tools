library scaffolding;

/*

Running this script will print:

----------------------- scaffolding -----------------------
file           libs' size     scaffolding    %
-----------------------------------------------------------
2838391        2415847        189468         8


You can see the file size, all the libs sizes added up, and the scaffolding.

There are two types of scaffolding:
1. Within a library. In the example above it is 8% = 189468 / 2415847 * 100
2. Global scaffolding. In the example above it is 15% = 100 - (2415847 / 2838391) * 100

*/

import 'common.dart';
import 'package:fp/fp.dart' as _;

main() {
  final s = scaffoldingInfo(new Dump("../app/build/web/sample_app.dart.js.info.json"));
  printScaffoldingInfo(s);
}


Map scaffoldingInfo(Dump a) {
  final file = a.json["outputUnits"].first["size"];
  final libs = a.reduceLibraries(0, (sum, lib) => sum + lib["size"]);
  final scaffolding = a.reduceLibraries(0, (sum, lib) => sum + (lib["size"] - a.sizeOfAllChildren(lib)));
  final percent = ((scaffolding / libs) * 100).round();
  return {"file" : file, "libs" : libs, "scaffolding" : scaffolding, "percent" : percent};
}

void printScaffoldingInfo(Map m) {
  print("----------------------- scaffolding -----------------------");
  printRow(["file", "libs' size", "scaffolding", '%'], [15, 15, 15, 5]);
  print("-----------------------------------------------------------");
  printRow([m["file"], m["libs"], m["scaffolding"], m["percent"]], [15, 15, 15, 5]);
}