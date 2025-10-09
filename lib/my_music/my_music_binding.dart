import 'package:get/get.dart';
import 'package:musicxy/my_music/my_music_controller.dart';

class MyMusicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyMusicController>(() => MyMusicController());
  }
}
