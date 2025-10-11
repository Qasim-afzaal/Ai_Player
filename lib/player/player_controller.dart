import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class PlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();

  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxDouble volume = 1.0.obs;
  final RxString currentTitle = ''.obs;
  final RxBool isLooping = false.obs; // ✅ NEW

  String? _currentAudioUrl;
  bool _hasSource = false;

  @override
  void onInit() {
    super.onInit();

    // Default playback mode
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

    // Listeners
    audioPlayer.onPositionChanged.listen((pos) => position.value = pos);
    audioPlayer.onDurationChanged.listen((dur) => duration.value = dur);
    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });
  }

  /// Play a new track from URL
  Future<void> playUrl(String url, {String? title}) async {
    currentTitle.value = title ?? url;
    _currentAudioUrl = url;
    _hasSource = true;

    await audioPlayer.stop();
    await audioPlayer.setSourceUrl(url);
    await audioPlayer.resume();
  }

  /// Play a local file
  Future<void> playLocalFile(String filePath, {String? title}) async {
    currentTitle.value = title ?? filePath.split('/').last;
    _currentAudioUrl = filePath;
    _hasSource = true;

    await audioPlayer.stop();
    await audioPlayer.setSourceDeviceFile(filePath);
    await audioPlayer.resume();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (!_hasSource) {
      const fallbackUrl =
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      await playUrl(fallbackUrl, title: 'SoundHelix Song 1');
      return;
    }

    if (isPlaying.value) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.resume();
    }
  }

  /// Toggle loop
  Future<void> toggleLoop() async {
    isLooping.value = !isLooping.value;
    await audioPlayer.setReleaseMode(
      isLooping.value ? ReleaseMode.loop : ReleaseMode.stop,
    );
  }

  /// Seek
  Future<void> seek(Duration newPosition) async {
    await audioPlayer.seek(newPosition);
  }

  /// Volume
  Future<void> setVolume(double v) async {
    volume.value = v;
    await audioPlayer.setVolume(v);
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
