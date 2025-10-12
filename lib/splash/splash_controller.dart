import 'package:get/get.dart';
import 'package:musicxy/routes/app_pages.dart';

class SplashController extends GetxController {


  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.offNamed(Routes.START);
    });

    super.onReady();
  }




}
