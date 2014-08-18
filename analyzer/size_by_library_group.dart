library size_by_library_group;

/*

Running this script will print the following table:

----- libs grouped by category ------
Group       Libs   Bytes     Percent
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

The script will also print detailed info about angular and core libs:

 ---------------------- libs angular -------------------------
Lib                                     Size      Percent
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
  final d = new Dump("../app/build/web/sample_app.dart.js.info.json");
  final g = groups(d);
  printGroups(g);

  printLibs(libsInGroup(g["groups"], "angular"));
  printLibs(libsInGroup(g["groups"], "dart"));
}

void printGroups(Map info) {
  final totals = info["totals"];
  final groups = info["groups"];
  pr(val) => printRow([val["group"], val["libsLength"], val["size"], "(${val["percent"]}%)"],  [12, 7, 10, 7]);

  print("----- libs grouped by category ------");
  printRow(["Group", "Libs", "Bytes", "Percent"],  [12, 7, 10, 7]);
  print('--------------------------------------');
  pr(totals);
  groups.forEach(pr);

  // Other mostly consists of _js_helper, _isolate_helper, _interceptors, so it cannot be made smaller.
}

Map groups(Dump a) {
  final grouped = a.groupByLibraries((lib) {
    final angularLibs = [
        'angular', 'change_detection'
    ];
    if (angularLibs.any((elib) => lib["name"].contains(elib))) return "angular";
    if (lib["name"].contains("di")) return "di";
    if (lib["name"].contains("dart")) return "dart";
    if (lib["name"].contains("route")) return "route";
    if (lib["name"].contains("generated_")) return "generated";
    if (lib["name"].contains("sample_app")) return "app";
    return "other";
  });

  final res = grouped.keys.fold([], (res, key) =>
    res..add({
        "group" : key,
        "size" : a.reduceSize(grouped[key]),
        "libs" : grouped[key],
        "libsLength" : grouped[key].length
    }));
  res.sort((a, b) => b["size"] - a["size"]);

  final totals = res.fold({"group" : "totals", "libsLength" : 0, "size" : 0, "percent" : 100}, (res, curr) {
    res["libsLength"] += curr["libsLength"];
    res["size"] += curr["size"];
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
  pr(val) => printRow([val["name"], val["size"], "${val["percent"]} (${val["normalizedPercent"]}%)"],  [40, 10, 12]);

  print("");
  print("---------------------- libs ${info["group"]} -------------------------");
  printRow(["Lib", "Size", "Percent"],  [40, 10, 12]);
  print('----------------------------------------------------------');
  pr(totals);
  libs.forEach(pr);
}

Map libsInGroup(List groups, String groupKey) {
  final group = groups.firstWhere((g) => g["group"] == groupKey);
  final libs = group["libs"];

  libs.sort((a, b) => b["size"] - a["size"]);

  final totals = {"name" : "totals", "size" : group["size"], "percent" : "100", "normalizedPercent" : group["percent"]};

  libs.forEach((res){
    final p = ((res["size"] / totals["size"]) * 100).round();
    res["percent"] = p;
    res["normalizedPercent"] = (p * (group["percent"] / 100)).round();
  });

  return {"libs" : libs, "totals" : totals, "group" : groupKey};
}