library launch_chrome;
import 'package:webdriver/webdriver.dart';

main() {
  final capabilities = Capabilities.chrome;
  capabilities["chromeOptions"] = {"args": [ "--enable-logging", "--v=1", "--user-data-dir=./chrome_logs" ]};
  WebDriver driver;

  WebDriver
  .createDriver(desiredCapabilities: capabilities)
  .then((_driver) {driver = _driver;})
  .then((_) => driver.get('http://localhost:8080/index.html'))
  .then((_) => driver.findElement(new By.id('dummy-id')))
  .then((element) => element.name);
}