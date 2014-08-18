cd app

rm -rf build

pub build --mode=debug

dart --old_gen_heap_size=1024  "$DART_SDK/lib/_internal/compiler/implementation/dart2js.dart" build/web/sample_app.dart -o build/web/sample_app.dart.js --dump-info
