library size_by_library_group;

/*

Running this script will print the following table:

----- libs grouped by category ------
Group       Libs   Bytes     %
--------------------------------------
totals      89     2415847   (100%)
angular     38     951777    (39%)
dart        17     763157    (32%)
other       17     437077    (18%)
generated   3      119660    (5%)
di          11     88956     (4%)
route       2      52329     (2%)
app         1      2891      (0%)

You can see that angular (+ di, route) accounts for 45% of the generated file. The dart core accounts for another 32%.
"other" mostly consists of _js_helper, _isolate_helper, _interceptors, so it cannot be made smaller.

The script will also print detailed info about the angular and core libs:

 ---------------------- libs angular -------------------------
Lib                                     Size      %
----------------------------------------------------------
totals                                  951777    100 (39%)
angular.core.dom_internal               258957    27 (11%)
angular.directive                       193123    20 (8%)
angular.core_internal                   73658     8 (3%)
angular.watch_group                     57015     6 (2%)
angular.core.parser.dynamic_parser_impl 35951     4 (2%)
angular.formatter_internal              33534     4 (2%)

So you can see that internal accounts for about 11% of the size of the app.
*/


import 'common.dart';
import 'package:fp/fp.dart' as _;

main() {
  final t = new Tracing("../chrome_logs/chrome_debug.log");
  final d = new Dump("../dumps/dump.json");
  final g = groups(d, t, "sample_app");
  printGroups(g);

  printLibs(libsInGroup(d, g["groups"], "angular"));
  printLibs(libsInGroup(d, g["groups"], "dart"));
  printLibs(libsInGroup(d, g["groups"], "other"));
}

void printGroups(Map info) {
  final totals = info["totals"];
  final groups = info["groups"];
  pr(val) => printRow([
      val["group"],
      val["libsLength"],
      val["numberOfFuncs"],
      val["size"],
      "(${val["percent"]}%)",
      val["deadLength"],
      "(${percent(val["deadLength"], val["numberOfFuncs"])}%)",
      val["deadSize"],
      "(${percent(val["deadSize"], val["size"])}%)"
  ],  [12, 7, 10, 7, 7, 10, 7, 11, 7]);

  print("----- libs grouped by category --------------------------------------------");
  printRow(["Group", "Libs", "Funcs", "Bytes", "%", "Dead Func", "%", "Dead Bytes", "%"],  [12, 7, 10, 7, 7, 10, 7, 11, 7]);
  print('---------------------------------------------------------------------------');
  pr(totals);
  groups.forEach(pr);

  // Other mostly consists of _js_helper, _isolate_helper, _interceptors, so it cannot be made smaller.
}

Map groups(Dump a, Tracing t, String app) {
  final grouped = a.groupByLibraries((lib) {
    final angularLibs = [
        'angular', 'change_detection'
    ];
    if (angularLibs.any((elib) => lib["name"].contains(elib))) return "angular";
    if (lib["name"].contains("di")) return "di";
    if (lib["name"].contains("dart")) return "dart";
    if (lib["name"].contains("route")) return "route";
    if (lib["name"].contains("generated_")) return "generated";
    if (lib["name"].contains(app)) return "app";
    return "other";
  });

  addDeadCode(libs) =>
      libs.forEach((lib) => lib.putIfAbsent("dead", () => t.deadCodeInLibrary(a, lib)));

  reduceDeadSize(libs) =>
      libs.fold(0, (m, c) => m + c["dead"]["deadSize"]);

  reduceDeadLength(libs) =>
      libs.fold(0, (m, c) => m + c["dead"]["deadLength"]);

  reduceNumberOfFuncs(libs) =>
      libs.fold(0, (m, c) => m + a.allFunctionsInLibrary(c).length);

  grouped.values.forEach((libs) => addDeadCode(libs));

  final res = grouped.keys.fold([], (res, key) =>
    res..add({
        "group" : key,
        "size" : a.reduceSize(grouped[key]),
        "libs" : grouped[key],
        "deadSize" : reduceDeadSize(grouped[key]),
        "deadLength" : reduceDeadLength(grouped[key]),
        "numberOfFuncs" : reduceNumberOfFuncs(grouped[key]),
        "libsLength" : grouped[key].length
    }));
  res.sort((a, b) => b["size"] - a["size"]);

  final totals = res.fold({"group" : "totals", "libsLength" : 0, "size" : 0, "percent" : 100, "deadSize" : 0, "deadLength" : 0, "numberOfFuncs" : 0}, (res, curr) {
    res["libsLength"] += curr["libsLength"];
    res["size"] += curr["size"];
    res["deadSize"] += curr["deadSize"];
    res["deadLength"] += curr["deadLength"];
    res["numberOfFuncs"] += curr["numberOfFuncs"];
    return res;
  });

  res.forEach((res){
    res["percent"] = ((res["size"] / totals["size"]) * 100).round();
  });

  return {"groups" : res, "totals" : totals};
}


void printLibs(Map info) {
  final totals = info["totals"];
  final libs = info["libs"];
  pr(val) => printRow([
      val["name"],
      val["numberOfFuncs"],
      val["size"],
      "${val["percent"]} (${val["normalizedPercent"]}%)",
      val["deadLength"],
      "(${percent(val["deadLength"], val["numberOfFuncs"])}%)",
      val["deadSize"],
      "(${percent(val["deadSize"], val["size"])}%)"
  ],  [40, 11, 11, 12, 11, 7, 11, 7]);

  print("");
  print("---------------------- libs ${info["group"]} -------------------------------------------------------------");
  printRow(["Lib", "Funcs", "Bytes", "%", "Dead Funcs", "%", "Dead Bytes", "%"],  [40, 11, 11, 12, 11, 7, 11, 7]);
  print('---------------------------------------------------------------------------------------------------');
  pr(totals);
  libs.forEach(pr);
}

Map libsInGroup(Dump a, List groups, String groupKey) {
  final group = groups.firstWhere((g) => g["group"] == groupKey);
  final libs = group["libs"];

  libs.sort((a, b) => b["size"] - a["size"]);

  final totals = {"name" : "totals", "size" : group["size"],
      "percent" : "100", "normalizedPercent" : group["percent"],
      "deadSize" : group["deadSize"], "deadLength" : group["deadLength"], "numberOfFuncs" : group["numberOfFuncs"]};

  libs.forEach((lib){
    final p = ((lib["size"] / totals["size"]) * 100).round();
    lib["percent"] = p;
    lib["normalizedPercent"] = (p * (group["percent"] / 100)).round();
    lib["deadSize"] = lib["dead"]["deadSize"];
    lib["deadLength"] = lib["dead"]["deadLength"];
    lib["numberOfFuncs"] = a.allFunctionsInLibrary(lib).length;
  });

  return {"libs" : libs, "totals" : totals, "group" : groupKey};
}