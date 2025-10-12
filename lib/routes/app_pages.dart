import 'package:get/get.dart';
import 'package:musicxy/home/home.dart';
import 'package:musicxy/home/home_binding.dart';
import 'package:musicxy/my_music/my_music_binding.dart';
import 'package:musicxy/my_music/my_music_screen.dart';
import 'package:musicxy/paywall_screen.dart';
import 'package:musicxy/splash/splash.dart';
import 'package:musicxy/splash/splash_binding.dart';
import 'package:musicxy/start/start_binding.dart';
import 'package:musicxy/start/start_screen.dart';
import 'package:musicxy/player/player_binding.dart';
import 'package:musicxy/player/player_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.PAYWALL;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.START,
      page: () => const StartScreen(),
      binding: StartBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const Home(),
      binding: HomeBinding(),
    ),
    // GetPage(
    //   name: _Paths.IMAGE_DISPLAY,
    //   page: () => const ImageDisplayScreen(),
    //   binding: ImageDisplayBinding(),
    // ),
    GetPage(
      name: _Paths.MY_MUSIC,
      page: () => const MyMusicScreen(),
      binding: MyMusicBinding(),
    ),
    GetPage(name: _Paths.PAYWALL, page: () => const PaywallScreen()),
    GetPage(
      name: _Paths.PLAYER,
      page: () => const PlayerScreen(),
      binding: PlayerBinding(),
    ),
  ];
}
