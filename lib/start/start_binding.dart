import 'package:get/get.dart';
import 'package:musicxy/home/home_controller.dart';
import 'package:musicxy/start/start_controller.dart';


class StartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<StartController>(
      () => StartController(),
    );
  }
}
