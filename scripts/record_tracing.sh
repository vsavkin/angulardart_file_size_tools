echo Record APP_DIR=$APP_DIR

rm -rf chrome_logs

dart scripts/static_file_server/serve_static_files.dart "$APP_DIR/build/web" &
HTTP_SERVER=$!
sleep 1

if ! kill -s 0 $HTTP_SERVER
then
   exit 1;
fi


java -jar selenium/selenium-server-standalone-2.39.0.jar -Dwebdriver.chrome.driver=selenium/chromedriver &
SELENIUM=$!
sleep 10


dart scripts/run_app/script.dart

kill -9 $SELENIUM
kill -9 $HTTP_SERVER

