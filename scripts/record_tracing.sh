rm -rf chrome_logs


java -jar selenium/selenium-server-standalone-2.39.0.jar -Dwebdriver.chrome.driver=selenium/chromedriver &
SELENIUM=$!

dart scripts/static_file_server/serve_static_files.dart &
HTTP_SERVER=$!

sleep 10

dart scripts/run_app/script.dart

kill -9 $SELENIUM
kill -9 $HTTP_SERVER

