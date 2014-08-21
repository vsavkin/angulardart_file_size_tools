library common;

import 'dart:io';
import 'dart:convert';
import 'package:fp/fp.dart' as _;

class Func {
  final String className;
  final String methodName;
  final Map info; // all the data about the function we get from dump info

  Func(this.className, this.methodName, [this.info]);

  operator == (Func func) =>
      className == func.className && methodName == func.methodName;

  toString() => "${className}.${methodName}";
}


class Tracing {
  List<Func> calls;

  Tracing(String fileName) {
    calls = _readAllFuncCallFromChromeDebugFile(new File(fileName).readAsLinesSync());
  }

  _readAllFuncCallFromChromeDebugFile(List<String> lines) {
    return lines
        .where((line) => line.contains("source: http://localhost:8080") && line.contains("INFO:CONSOLE"))
        .map((line) => line.substring(line.indexOf("\"") + 1, line.lastIndexOf("\"")))
        .map((line) => line.substring(line.lastIndexOf(":") + 1))
        .map((line) => line.split("."))
        .where((line) => line.length == 2)
        .map((ps) => new Func(ps[0], ps[1])).toList();
  }

  deadCodeInLibrary(Dump a, Map lib) {
    final allFuncs = a.allFunctionsInLibrary(lib);
    final allLength = allFuncs.length;
    final allSize = a.reduceSize(allFuncs.map(_.getField("info")));

    final dead = subLists(allFuncs, calls);
    final deadLength = dead.length;
    final deadSize = a.reduceSize(dead.map(_.getField("info")));

    final percentLength = percent(deadLength, allLength);
    final percentSize = percent(deadSize, allSize);

    return {
        "percentLength" : percentLength,
        "percentSize" : percentSize,
        "deadLength" : deadLength,
        "deadSize" : deadSize,
        "deadFuncs" : dead
    };
  }
}

class Dump {
  Map json;

  Dump(String fileName) {
    final data = new File(fileName).readAsStringSync();
    json = new JsonDecoder().convert(data);
  }

  List<Func> get allFunctionsInDump =>
      reduceLibraries([], (list, lib) => list..addAll(allFunctionsInLibrary(lib)));

  /**
   * Execute call back for every library.
   */
  forEachLibrary(fn) {
    json["elements"]["library"].values.forEach(fn);
  }

  List<Func> allFunctionsInLibrary(Map lib) {
    return reduceChildren(lib, [], (list, child) {
      if (child["kind"] == "class") {
        list.addAll(allFunctionsInClass(child));
      } else {
        list.add(new Func("", child["name"], child));
      }
      return list;
    });
  }

  List<Func> allFunctionsInClass(Map clazz) {
    return reduceChildren(clazz, [], (list, child) => list..add(new Func(clazz["name"], child["name"], child)));
  }

  Map groupByLibraries(fn) {
    return json["elements"]["library"].values.fold({}, (res, lib) {
      final libs = res.putIfAbsent(fn(lib), () => []);
      libs.add(lib);
      return res;
    });
  }

  reduceLibraries(init, fn) {
    return json["elements"]["library"].values.fold(init, fn);
  }

  reduceChildren(Map lib, init, fn) {
    findChild(id) {
      final parts = id.split("/");
      return json["elements"][parts[0]][parts[1]];
    }
    return lib["children"].map(findChild).fold(init, fn);
  }

  size(Map obj) => obj["size"] == null ? 0 : obj["size"];

  num sizeOfAllChildren(Map lib) {
    return reduceChildren(lib, 0, (a,b) {
      return a + size(b);
    });
  }

  num reduceSize(obj) => obj.fold(0, (sum, obj) => sum + size(obj));
}

void printRow(List values, List sizes) {
  final s = zip(values, sizes)
      .map((pair) =>pair[0].toString().padRight(pair[1], " "))
      .join("");
  print(s);
}

List zip(List a, List b) {
  if (a.length != b.length) throw "not equal size";

  final res = [];
  for(var i = 0; i < a.length; ++i) {
    final aa = a[i];
    final bb = b[i];
    res.add([aa, bb]);
  }

  return res;
}

List subLists(List a, List b) => a.where((aa) => !b.contains(aa)).toList();

percent(a, b) {
  if (b == 0) return 100;
  return ((a / b) * 100).round();
}