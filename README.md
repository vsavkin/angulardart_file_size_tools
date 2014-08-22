# Measuring File Size of AngularDart Apps



## Set up

* Install Java
* Install Dart >= 1.6.0-dev.8.0
* Clone the repo
* Run `./scripts/setup.sh`



## Dump Info

Run `./scripts/dumpinfo.sh` to generate:
* `dumps/dump.json`

This file will contain detailed information about everything in the generated js file: libraries, classes, fields, their size, types, etc.


## Tracing

To enable tracing:
* Open `dart-sdk/lib/_internal/compiler/implementation/js_backend/backend.dart`
* Set `TRACE_CALLS` to true.

Run ./scripts/tracing.sh to generate:
* `chrome_logs/chrome_debug.log`

When TRACE_CALLS is set to true, the dart2js compiler adds special tracing calls outputting information about all function calls into the console.


## Analyzing the Results

You can analyze `dumps/dump.json` using http://dart-lang.github.io/dump-info-visualizer/build/web/viewer.html

The analyzer directory contains a bunch of Dart scripts that run analysis using  `dumps/dump.json` and `chrome_logs/chrome_debug.log`. Run `dumpinfo.sh` and `tracing.sh` before running the scripts.



## Scripts

Run `main.dart` to generate:

```
----- libs grouped by category --------------------------------------------
Group       Libs   Funcs     Bytes  %      Dead Func %      Dead Bytes %
---------------------------------------------------------------------------
totals      89     2591      546835 (100%) 2259      (87%)  278199     (51%)
angular     38     893       208429 (38%)  805       (90%)  110031     (53%)
dart        17     1201      176844 (32%)  1047      (87%)  111363     (63%)
other       17     363       95980  (18%)  291       (80%)  36688      (38%)
generated   3      0         33295  (6%)   0         (100%) 0          (0%)
di          11     87        20936  (4%)   69        (79%)  11260      (54%)
route       2      47        10844  (2%)   47        (100%) 8857       (82%)
app         1      0         507    (0%)   0         (100%) 0          (0%)


---------------------- libs angular -------------------------------------------------------------------
Lib                                     Funcs      Bytes      %           Dead Funcs %      Dead Bytes %
--------------------------------------------------------------------------------------------------------
totals                                  893        208429     100 (38%)   805        (90%)  110031     (53%)
angular.core.dom_internal               181        53697      26 (10%)    149        (82%)  24578      (46%)
angular.directive                       204        41795      20 (8%)     204        (100%) 23890      (57%)
angular.core_internal                   82         15904      8 (3%)      50         (61%)  5828       (37%)
angular.watch_group                     58         11453      5 (2%)      53         (91%)  6448       (56%)
angular.animate                         39         9179       4 (2%)      39         (100%) 7357       (80%)
angular.node_injector                   20         9171       4 (2%)      8          (40%)  1842       (20%)
angular.introspection                   6          8448       4 (2%)      6          (100%) 2054       (24%)
angular.formatter_internal              25         8412       4 (2%)      25         (100%) 6455       (77%)
angular.core.parser.dynamic_parser_impl 25         7635       4 (2%)      25         (100%) 7548       (99%)
angular.change_detection.ast_parser     23         5729       3 (1%)      23         (100%) 3212       (56%)
angular.routing                         14         4523       2 (1%)      14         (100%) 1982       (44%)
angular.core.parser.lexer               35         4431       2 (1%)      35         (100%) 4063       (92%)
angular.util                            0          3999       2 (1%)      0          (100%) 0          (0%)


---------------------- libs dart -------------------------------------------------------------------------
Lib                                     Funcs      Bytes      %           Dead Funcs %      Dead Bytes %
----------------------------------------------------------------------------------------------------------
totals                                  1201       176844     100 (32%)   1047       (87%)  111363     (63%)
dart.dom.html                           441        45311      26 (8%)     411        (93%)  28132      (62%)
dart.async                              199        36124      20 (6%)     164        (82%)  20232      (56%)
dart.collection                         200        27126      15 (5%)     135        (68%)  16502      (61%)
dart.core                               109        25837      15 (5%)     100        (92%)  20433      (79%)
dart.convert                            72         14093      8 (3%)      72         (100%) 11971      (85%)
dart._internal                          92         12583      7 (2%)      80         (87%)  7367       (59%)
dart.js                                 18         5029       3 (1%)      15         (83%)  1931       (38%)
dart.dom.svg                            42         4787       3 (1%)      42         (100%) 2320       (48%)
dart.typed_data.implementation          28         4508       3 (1%)      28         (100%) 2475       (55%)
```


## Other Apps

You can run all the scripts for any app. To do that set the APP_DIR and FILE env variables.

```
APP_DIR=/path/myapp FILE=main_file.dart ./scripts/dumpinfo.sh
APP_DIR=/path/myapp FILE=main_file.dart ./scripts/tracing.sh
```

You don't have to change any of the dart scripts.


## Accuracy and Scaffolding

1. Dart2JS generates global scaffolding (about 20% for an empty AngularDart app).
2. Dart2JS generates local scaffolding (about 11%).
3. We don't know what fields are being used.

Considering all of these we don't know exactly how much a particular function accounts for. It is just an estimate.




