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

You can analyze `dumps/dump.json` using http://dart-lang.github.io/dump-info-visualizer/build/web/viewer.html

The analyzer directory contains a bunch of Dart scripts that run some analysis using  `dumps/dump.json` and `chrome_logs/chrome_debug.log`. Run `tracing.sh` before running the scripts.



## Scripts

`size_by_library_group.dart`  generates:

```
----- libs grouped by category --------------------------
Group       Libs   Bytes     %      Dead      Dead %
---------------------------------------------------------
totals      155    835175    (100%) 584248    (70%)
other       61     239019    (29%)  174737    (73%)
angular     38     214686    (26%)  138431    (64%)
dart        18     184043    (22%)  127880    (69%)
di          33     143817    (17%)  131814    (92%)
generated   3      40632     (5%)   0         (0%)
route       2      12978     (2%)   11386     (88%)


---------------------- libs angular ---------------------------------------
Lib                                     Size      %           Dead Size   Dead %
------------------------------------------------------------------------------
totals                                  214686    100 (26%)   138431      (64%)
angular.core.dom_internal               56221     26 (7%)     29176       (52%)
angular.directive                       42382     20 (5%)     30452       (72%)
angular.core_internal                   16273     8 (2%)      6888        (42%)
angular.watch_group                     11554     5 (1%)      7534        (65%)
angular.animate                         9667      5 (1%)      7863        (81%)
angular.node_injector                   9161      4 (1%)      2017        (22%)
angular.formatter_internal              8819      4 (1%)      7057        (80%)
angular.introspection                   8446      4 (1%)      4874        (58%)
angular.core.parser.dynamic_parser_impl 7639      4 (1%)      7565        (99%)
angular.routing                         5952      3 (1%)      3774        (63%)
angular.change_detection.ast_parser     5823      3 (1%)      5535        (95%)
angular.core.parser.lexer               4456      2 (1%)      4125        (93%)
angular.util                            4000      2 (1%)      3652        (91%)
angular.core.parser.syntax              2920      1 (0%)      2421        (83%)
angular.core.parser.eval                2604      1 (0%)      2270        (87%)
angular.core.parser.dynamic_parser      2328      1 (0%)      2083        (89%)


---------------------- libs dart ---------------------------------------
Lib                                     Size      %           Dead Size   Dead %
------------------------------------------------------------------------------
totals                                  184043    100 (22%)   127880      (69%)
dart.dom.html                           47897     26 (6%)     34270       (72%)
dart.async                              36983     20 (4%)     24171       (65%)
dart.collection                         28860     16 (4%)     18415       (64%)
dart.core                               25957     14 (3%)     21809       (84%)
dart.convert                            14320     8 (2%)      12853       (90%)
dart._internal                          12959     7 (2%)      7881        (61%)
dart.dom.svg                            5435      3 (1%)      2727        (50%)
dart.js                                 5016      3 (1%)      2149        (43%)
dart.typed_data.implementation          4969      3 (1%)      2841        (57%)
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
all         dead        %g
2097229     1543402     74
```

## Changing App

You can profile any app, not just "sample_app". To do that set the APP_DIR and FILE env variables.

```
APP_DIR=/myapp FILE=main_file.dart ./scripts/tracing.sh
APP_DIR=/myapp FILE=main_file.dart ./scripts/dumpinfo.sh
```

You don't have to change any of the dart scripts.

## Notes

* With tracing enabled the file size will increase significantly. If you want to be precise about the size, disable tracing and use `dumpinfo.sh`.





