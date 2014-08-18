# Measuring File Size of AngularDart Apps



## Set up

* Install Java
* Install Dart >= 1.6.0-dev.8.0
* Clone the repo
* Run `./scripts/setup.sh`



## Dump Info

Run `./scripts/dumpinfo.sh` to generate:
* `app/build/web/sample_app.dart.js.info.json`



## Dump Info + Tracing

To enable tracing:
* Open `dart-sdk/lib/_internal/compiler/implementation/js_backend/backend.dart`
* Set `TRACE_CALLS` to true.

Run ./scripts/tracing.sh to generate:
* `app/build/web/sample_app.dart.js.info.json`
* `chrome_logs/chrome_debug.log`



## Analyzing the Results

You can analyze `sample_app.dart.js.info.json` using http://dart-lang.github.io/dump-info-visualizer/build/web/viewer.html

The analyzer directory contains a bunch of Dart scripts that run some analysis using  `app/build/web/sample_app.dart.js.info.json` and `chrome_logs/chrome_debug.log`. Run `tracing.sh` before running the scripts.



## Scripts

`size_by_library_group.dart`  generates:

```
----- libs grouped by category ------
Group       Libs   Bytes     %
--------------------------------------
totals      89     546835    (100%)
angular     38     208429    (38%)
dart        17     176844    (32%)
other       17     95980     (18%)
generated   3      33295     (6%)
di          11     20936     (4%)
route       2      10844     (2%)
app         1      507       (0%)

---------------------- libs angular -------------------------
Lib                                     Size      %
----------------------------------------------------------
totals                                  208429    100 (38%)
angular.core.dom_internal               53697     26 (10%)
angular.directive                       41795     20 (8%)
angular.core_internal                   15904     8 (3%)
angular.watch_group                     11453     5 (2%)
angular.animate                         9179      4 (2%)
angular.node_injector                   9171      4 (2%)
angular.introspection                   8448      4 (2%)
angular.formatter_internal              8412      4 (2%)
angular.core.parser.dynamic_parser_impl 7635      4 (2%)
angular.change_detection.ast_parser     5729      3 (1%)
angular.routing                         4523      2 (1%)
angular.core.parser.lexer               4431      2 (1%)
angular.util                            3999      2 (1%)


---------------------- libs dart -------------------------
Lib                                     Size      %
----------------------------------------------------------
totals                                  176844    100 (32%)
dart.dom.html                           45311     26 (8%)
dart.async                              36124     20 (6%)
dart.collection                         27126     15 (5%)
dart.core                               25837     15 (5%)
dart.convert                            14093     8 (3%)
dart._internal                          12583     7 (2%)
dart.js                                 5029      3 (1%)
dart.dom.svg                            4787      3 (1%)
dart.typed_data.implementation          4508      3 (1%)
dart.math                               646       0 (0%)
```



`scaffolding.dart` generates:

```
----------------------- scaffolding -----------------------
file           libs' size     scaffolding    %
-----------------------------------------------------------
789508         546835         61035          11
```



`dead_code.dart` generates:

```
---------------- number of methods ----------------
all         dead        %
5034        4467        89

----------------------- size ----------------------
all         dead        %
2097229     1543402     74
```


## Notes

* With tracing enabled the file size will increase significantly. If you want to be precise about the size, disable tracing and use `dumpinfo.sh`.





