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

The analyzer directory contains Dart scripts that run some analysis using  `app/build/web/sample_app.dart.js.info.json` and `chrome_logs/chrome_debug.log`. Run `tracing.sh` before running the scripts.





