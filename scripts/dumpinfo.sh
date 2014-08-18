rm -rf app/build

cd app

pub build --mode=debug

dart2js build/web/sample_app.dart -o build/web/sample_app.dart.js --dump-info -m