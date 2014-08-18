library sample_app;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@Component(
    selector: 'dummy',
    template: '<div id="dummy-id">!dummy!</div>',
    useShadowDom: false
)
class Dummy {}

main() {
  applicationFactory().addModule(new Module()..bind(Dummy)).run();
}