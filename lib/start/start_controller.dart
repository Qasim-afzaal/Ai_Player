import 'package:get/get.dart';
import 'package:musicxy/routes/app_pages.dart';

class StartController extends GetxController {
  void navigateToHome() {
    Get.offAllNamed(Routes.HOME);
  }
}
