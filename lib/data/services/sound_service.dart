import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  // Пути к звукам (без префикса assets/, так как AssetSource добавляет его сам)
  static const String _successSound = 'sounds/success.mp3';
  static const String _xpSound = 'sounds/xp.mp3';
  static const String _completeSound = 'sounds/complete.mp3';
  static const String _clickSound = 'sounds/click.mp3';

  void toggleMute() {
    _isMuted = !_isMuted;
    debugPrint('Sound service: ${_isMuted ? 'Muted' : 'Unmuted'}');
  }

  Future<void> _playSound(String path) async {
    if (_isMuted) return;
    try {
      // Для веба на GitHub Pages важно поймать 404, чтобы не вешать приложение
      await _player.play(AssetSource(path)).catchError((e) {
        return null;
      });
    } catch (e) {
      // Игнорируем ошибки отсутствующих файлов
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
