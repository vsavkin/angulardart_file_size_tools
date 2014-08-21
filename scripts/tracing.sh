APP_DIR=${APP_DIR:=app}
FILE=${FILE:=sample_app.dart}

APP_DIR=$APP_DIR FILE=$FILE ./scripts/compile_tracing.sh

sleep 5

APP_DIR=$APP_DIR ./scripts/record_tracing.sh