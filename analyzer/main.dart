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

main(List<String> args) {
  final t = new Tracing("../chrome_logs/chrome_debug.log");
  final d = new Dump("../dumps/dump.json");
  final g = groups(d, t, "sample_app");

  print("All funcs: ${g["totals"]["size"]}, File size: ${d.fileSize}");

  printGroups(g);

  printLibs(libsInGroup(d, g["groups"], "angular"));
  printLibs(libsInGroup(d, g["groups"], "dart"));
  printLibs(libsInGroup(d, g["groups"], "other"));
}

void printGroups(Map info) {
  final totals = info["totals"];
  final groups = info["groups"];

  final output = rowOutput([12, 7, 10, 7, 7, 10, 7, 11, 7]);

  printHeaders() {
    print("----- libs grouped by category --------------------------------------------");
    output(["Group", "Libs", "Funcs", "Bytes", "%", "Dead Func", "%", "Dead Bytes", "%"]);
    print('---------------------------------------------------------------------------');
  }

  printRow(val) {
    output([
        val["group"], val["libsLength"], val["numberOfFuncs"], val["size"], "(${val["percentage"]}%)",
        val["numberOfDeadFuncs"], "(${val["percentageOfDeadFuncs"]}%)",
        val["deadSize"], "(${val["percentageOfDeadCode"]}%)"]);
  }

  printHeaders();
  printRow(totals);
  groups.forEach(printRow);
}

Map groups(Dump a, Tracing t, String appName) {
  final grouped = a.groupByLibraries((lib) {
    final angularLibs = [
        'angular', 'change_detection'
    ];
    if (angularLibs.any((alib) => lib["name"].contains(alib))) return "angular";
    if (lib["name"].contains("di")) return "di";
    if (lib["name"].contains("dart")) return "dart";
    if (lib["name"].contains("route")) return "route";
    if (lib["name"].contains("generated_")) return "generated";
    if (lib["name"].contains(appName)) return "app";
    return "other";
  });



  setDeadCode(libs) {
    libs.forEach((lib) => lib.putIfAbsent("dead", () => t.deadCodeInLibrary(a, lib)));
  }

  setFuncsSize(libs) {
    libs.forEach((lib) {
      lib["size"] = a.allFunctionsInLibrary(lib).fold(0, (m, c) => m + c.info["size"]);
    });
  }



  sizeOfAllDeadFuncs(libs) => libs.fold(0, (m, c) => m + c["dead"]["size"]);

  numberOfDeadFuncs(libs) => libs.fold(0, (m, c) => m + c["dead"]["numberOfFuncs"]);

  numberOfFuncs(libs) => libs.fold(0, (m, c) => m + a.allFunctionsInLibrary(c).length);


  grouped.values.forEach(setFuncsSize);
  grouped.values.forEach(setDeadCode);



  final groupedFns = grouped.keys.fold([], (res, key) {
    final size = a.reduceSize(grouped[key]);
    final deadSize = sizeOfAllDeadFuncs(grouped[key]);
    final nof = numberOfFuncs(grouped[key]);
    final nodf = numberOfDeadFuncs(grouped[key]);

    res.add({
        "group" : key,
        "libs" : grouped[key], "libsLength" : grouped[key].length,
        "size" : size, "deadSize" : deadSize, "percentageOfDeadCode" : percent(deadSize, size),
        "numberOfFuncs" : nof, "numberOfDeadFuncs" : nodf, "percentageOfDeadFuncs" : percent(nodf, nof)
    });
    return res;
  });
  groupedFns.sort((a, b) => b["size"] - a["size"]);




  final totals = groupedFns.fold({"group" : "totals", "libsLength" : 0, "size" : 0, "deadSize" : 0,
      "percentage" : 100, "numberOfFuncs" : 0, "numberOfDeadFuncs" : 0}, (res, curr) {

    res["libsLength"] += curr["libsLength"];
    res["size"] += curr["size"];
    res["deadSize"] += curr["deadSize"];
    res["numberOfDeadFuncs"] += curr["numberOfDeadFuncs"];
    res["numberOfFuncs"] += curr["numberOfFuncs"];

    return res;
  });
  totals["percentageOfDeadCode"] = percent(totals["deadSize"], totals["size"]);
  totals["percentageOfDeadFuncs"] = percent(totals["numberOfDeadFuncs"], totals["numberOfFuncs"]);




  groupedFns.forEach((res){
    res["percentage"] = percent(res["size"], totals["size"]);
  });

  return {"groups" : groupedFns, "totals" : totals};
}





void printLibs(Map info) {
  final output = rowOutput([40, 11, 11, 12, 11, 7, 11, 7]);

  printHeaders() {
    print("");
    print("---------------------- libs ${info["group"]} -------------------------------------------------------------");
    output(["Lib", "Funcs", "Bytes", "%", "Dead Funcs", "%", "Dead Bytes", "%"]);
    print('---------------------------------------------------------------------------------------------------');
  }

  printRow(val) {
    output([
        val["name"],
        val["numberOfFuncs"],
        val["size"],
        "${val["percentage"]} (${val["normalizedPercentage"]}%)",
        val["numberOfDeadFuncs"],
        "(${val["percentageOfDeadFuncs"]}%)",
        val["deadSize"],
        "(${val["percentageOfDeadCode"]}%)"
    ]);
  }

  final totals = info["totals"];
  final libs = info["libs"];

  printHeaders();
  printRow(totals);
  libs.forEach(printRow);
}


Map libsInGroup(Dump a, List groups, String groupKey) {
  final group = groups.firstWhere((g) => g["group"] == groupKey);
  final libs = group["libs"];
  libs.sort((a, b) => b["size"] - a["size"]);

  final totals = {"name" : "totals",
      "percentage" : "100", "normalizedPercentage" : group["percentage"],

      "size" : group["size"], "deadSize" : group["deadSize"],
      "percentageOfDeadCode" : percent(group["deadSize"], group["size"]),

      "numberOfFuncs" : group["numberOfFuncs"], "numberOfDeadFuncs" : group["numberOfDeadFuncs"],
      "percentageOfDeadFuncs" : percent(group["numberOfDeadFuncs"], group["numberOfFuncs"])};

  libs.forEach((lib){
    final p = percent(lib["size"], totals["size"]);;
    lib["percentage"] = p;
    lib["normalizedPercentage"] = (p * (group["percentage"] / 100)).round();
    lib["deadSize"] = lib["dead"]["size"];
    lib["percentageOfDeadCode"] = percent(lib["dead"]["size"], lib["size"]);

    lib["numberOfFuncs"] = a.allFunctionsInLibrary(lib).length;
    lib["numberOfDeadFuncs"] = lib["dead"]["numberOfFuncs"];
    lib["percentageOfDeadFuncs"] = percent(lib["numberOfDeadFuncs"], lib["numberOfFuncs"]);
  });

  return {"libs" : libs, "totals" : totals, "group" : groupKey};
}