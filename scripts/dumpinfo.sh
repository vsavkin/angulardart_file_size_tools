rm -rf ./dumps
mkdir ./dumps
DUMPS=$(pwd)/dumps

APP_DIR=${APP_DIR:=app}
FILE=${FILE:=sample_app.dart}

cd $APP_DIR

rm -rf build

pub build --mode=debug

dart2js "build/web/$FILE" -o "build/web/$FILE.js" --dump-info -m
cp "build/web/$FILE.js.info.json" $DUMPS/dump.json