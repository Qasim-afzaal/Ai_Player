import 'package:get/get.dart';

import 'package:musicxy/home/home_controller.dart';
import 'package:musicxy/my_music/my_music_controller.dart';
import 'package:musicxy/player/player_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MyMusicController>(() => MyMusicController());
    Get.lazyPut<PlayerController>(() => PlayerController());
  }
}
