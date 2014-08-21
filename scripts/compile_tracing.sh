echo Compile APP_DIR=$APP_DIR FILE=$FILE

cd $APP_DIR

rm -rf build

pub build --mode=debug

dart --old_gen_heap_size=1024  "$DART_SDK/lib/_internal/compiler/implementation/dart2js.dart" "build/web/$FILE" -o "build/web/$FILE.js"