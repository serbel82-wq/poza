import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  // Звуковые эффекты - в реальном проекте добавьте файлы в assets
  static const String _successSound = 'sounds/success.mp3';
  static const String _xpSound = 'sounds/xp.mp3';
  static const String _completeSound = 'sounds/complete.mp3';
  static const String _clickSound = 'sounds/click.mp3';

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    debugPrint('Sound muted: $_isMuted');
  }

  Future<void> _playSound(String path) async {
    if (_isMuted) return;
    try {
      // На вебе AudioPlayers может выдавать ошибку, если файл не найден или формат не поддерживается
      await _player.play(AssetSource(path));
    } catch (e) {
      debugPrint('Sound playing skipped: $path. Error: $e');
    }
  }

  Future<void> playSuccess() async => _playSound(_successSound);
  Future<void> playXP() async => _playSound(_xpSound);
  Future<void> playComplete() async => _playSound(_completeSound);
  Future<void> playClick() async => _playSound(_clickSound);

  void dispose() {
    _player.dispose();
  }
}
