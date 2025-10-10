import 'package:get/get.dart';
import 'package:musicxy/player/player_controller.dart';

class PlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlayerController>(() => PlayerController());
  }
}
