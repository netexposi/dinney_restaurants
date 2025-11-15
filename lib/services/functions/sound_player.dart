import 'package:just_audio/just_audio.dart';

class SoundEffectPlayer {
  static final _player = AudioPlayer();

  static Future<void> preload() async {
    await _player.setAsset('assets/sounds/popup.mp3');
  }

  static Future<void> play() async {
    await _player.seek(Duration.zero);
    await _player.play();
  }

  static void dispose() {
    _player.dispose();
  }
}
