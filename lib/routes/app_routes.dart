part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const START = _Paths.START;
  static const WEBVIEW = _Paths.WEBVIEW;
  static const HOME = _Paths.HOME;
  static const MY_MUSIC = _Paths.MY_MUSIC;
  static const PAYWALL = _Paths.PAYWALL;
  static const PLAYER = _Paths.PLAYER;

  static const FACEBOOK = _Paths.FACEBOOK;
  static const INSTAGRAM = _Paths.INSTAGRAM;
  static const YOUTUBE = _Paths.YOUTUBE;
  static const TWITTER = _Paths.TWITTER;
  static const TIKTOK = _Paths.TIKTOK;
  static const REDDIT = _Paths.REDDIT;
  static const SNAPCHAT = _Paths.SNAPCHAT;
  static const PINTEREST = _Paths.PINTEREST;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const START = '/start';
  static const WEBVIEW = '/web_view';
  static const HOME = '/home';
  static const MY_MUSIC = '/my_music';
  static const PAYWALL = '/paywall';
  static const PLAYER = '/player';
  static const FACEBOOK = '/facebook';
  static const INSTAGRAM = '/instagram';
  static const YOUTUBE = '/youtube';
  static const TWITTER = '/twitter';
  static const TIKTOK = '/tiktok';
  static const REDDIT = '/reddit';
  static const SNAPCHAT = '/snapchat';
  static const PINTEREST = '/pinterest';
}
