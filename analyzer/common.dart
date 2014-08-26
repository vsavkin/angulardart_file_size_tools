library common;

import 'dart:io';
import 'dart:convert';
import 'package:fp/fp.dart' as _;

class Func {
  final String className;
  final String methodName;
  String libraryName;
  final Map info; // all the data about the function we get from dump info
  final Map parentInfo;

  Func(this.className, this.methodName, [this.info, this.parentInfo]);

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

    final dead = deadCode(allFuncs, calls);
    final deadLength = dead.length;
    final deadSize = a.reduceSize(dead.map(_.getField("info")));

    final percentLength = percent(deadLength, allLength);
    final percentSize = percent(deadSize, allSize);

    return {
        "percentLength" : percentLength,
        "percentSize" : percentSize,
        "numberOfFuncs" : deadLength,
        "size" : deadSize,
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

  num get fileSize => json["outputUnits"].first["size"];

  /**
   * Execute call back for every library.
   */
  forEachLibrary(fn) {
    json["elements"]["library"].values.forEach(fn);
  }

  library(name) {
    return json["elements"]["library"].values.firstWhere((lib) => lib["name"] == name);
  }

  List<Func> allFunctionsInLibrary(Map lib) {
    return allInLibrary(lib, includeFunc)
      .map((data) {
        final className = (data["parent"] == null || data["parent"]["kind"] != "class") ? "" : data["parent"]["name"];
        return new Func(className, data["node"]["name"], data["node"], data["parent"]);
      })
      .map((func) => func..libraryName = lib["name"]);
  }

  List allInLibrary(Map lib, Function predicate) {
    final r = [];
    flatten(lib, null, r, predicate);
    return r;
  }

  void flatten(node, parent, list, predicate) {
    if (node is String) {
      flatten(byId(node), parent, list, predicate);
    } else if (node is Iterable) {
      node.forEach((n) => flatten(n, parent, list, predicate));
    } else {
      node["parent"] = parent;
      if (node["children"] != null) {
        flatten(node["children"], node, list, predicate);
      }
      if (predicate(node)) list.add({"node": node, "parent" : parent});;
    }
  }

  bool includeFunc(method) =>
      (method["kind"] == "method" || method["kind"] == "function" || method["kind"] == "constructor") && method["size"] != null && method["size"] > 0;

  Map groupByLibraries(fn) => _.groupBy(json["elements"]["library"].values, fn);

  reduceLibraries(init, fn) {
    return json["elements"]["library"].values.fold(init, fn);
  }

  reduceChildren(Map lib, init, fn) {
    return lib["children"].map(byId).fold(init, fn);
  }

  Map byId(id) {
    final parts = id.split("/");
    return json["elements"][parts[0]][parts[1]];
  }

  size(Map obj) => obj["size"] == null ? 0 : obj["size"];

  num sizeOfAllChildren(Map lib) {
    return reduceChildren(lib, 0, (a,b) {
      return a + size(b);
    });
  }

  num reduceSize(obj) => obj.fold(0, (sum, obj) => sum + size(obj));
}

rowOutput(List sizes) => (List values) => printRow(values, sizes);

printRow(List values, List sizes) {
  final s = _.zip(values, sizes)
      .map((pair) =>pair[0].toString().padRight(pair[1], " "))
      .join("");
  print(s);
}


List subLists(List a, List b) => a.where((aa) => !b.contains(aa)).toList();

List deadCode(List allFuncs, List calledFuncs) {
  var res = subLists(allFuncs, calledFuncs);
  return res.where((fn) {
    if (fn.parentInfo["kind"] == "class" || fn.parentInfo["kind"] == "library") return true;
    if (fn.parentInfo["kind"] == "field") return false; //we cannot trace fields, so we assume that all fields are used.
    if (fn.parentInfo["kind"] == "method" || fn.parentInfo["kind"] == "function") {
      final grandparent = fn.parentInfo["parent"];
      return res.contains(new Func(grandparent["name"], fn.parentInfo["name"]));
    }
    return true;
  }).toList();
}

percent(a, b) {
  if (b == 0) return 100;
  return ((a / b) * 100).round();
}