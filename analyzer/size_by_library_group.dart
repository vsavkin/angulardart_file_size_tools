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

You can see that angular (di + route) accounts for 45% of the generated file. The dart core accounts for another 32%.
"other" mostly consists of _js_helper, _isolate_helper, _interceptors, so it cannot be made smaller.
*/


import 'common.dart';
import 'package:fp/fp.dart' as _;

main() {
  final libs = libsByGroup(new Dump("../app/build/web/sample_app.dart.js.info.json"));
  printLibsByGroup(libs);
}

void printLibsByGroup(Map info) {
  final totals = info["totals"];
  final groups = info["groups"];
  pr(val) => printRow([val["group"], val["libs"], val["size"], "(${val["percent"]}%)"],  [12, 7, 10, 7]);

  print("----- libs grouped by category ------");
  printRow(["Group", "Libs", "Bytes", "Percent"],  [12, 7, 10, 7]);
  print('--------------------------------------');
  pr(totals);
  groups.forEach(pr);

  // Other mostly consists of _js_helper, _isolate_helper, _interceptors, so it cannot be made smaller.
}

Map libsByGroup(Dump a) {
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
        "libs" : grouped[key].length
    }));
  res.sort((a, b) => b["size"] - a["size"]);

  final totals = res.fold({"group" : "totals", "libs" : 0, "size" : 0, "percent" : 100}, (res, curr) {
    res["libs"] += curr["libs"];
    res["size"] += curr["size"];
    return res;
  });

  res.forEach((res){
    res["percent"] = ((res["size"] / totals["size"]) * 100).round();
  });

  return {"groups" : res, "totals" : totals};
}