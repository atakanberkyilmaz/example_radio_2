import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RadioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _currentUrl = '';
  bool _isPlaying = false;
  int _currentRadioIndex = 0;

  List<String> _radioUrls = []; // Firestore'dan çekilecek

  String get currentUrl => _currentUrl;
  bool get isPlaying => _isPlaying;
  AudioPlayer get audioPlayer => _audioPlayer;
  List<String> get radioUrls => _radioUrls; // Radio URLs getter

  RadioProvider() {
    _fetchRadioUrls(); // Başlangıçta URL'leri çek
  }

  Future<void> _fetchRadioUrls() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('radios').get();
      _radioUrls = querySnapshot.docs.map((doc) => doc['url'] as String).toList();
      if (_radioUrls.isNotEmpty) {
        await playRadio(_radioUrls[0]);
      }
    } catch (e) {
      print("Error fetching radio URLs: $e");
    }
  }

  Future<void> playRadio(String url) async {
    if (_currentUrl != url) {
      await _audioPlayer.setUrl(url);
      _currentUrl = url;
    }
    _audioPlayer.play();
    _isPlaying = true;
    _showNotification();
    notifyListeners();
  }

  Future<void> stopRadio() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _showNotification(); // Bildirimi güncelle
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    } else {
      await _audioPlayer.play();
      _isPlaying = true;
    }
    _showNotification(); // Bildirimi güncelle
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    notifyListeners();
  }

  Future<void> nextRadio() async {
    _currentRadioIndex = (_currentRadioIndex + 1) % _radioUrls.length;
    await playRadio(_radioUrls[_currentRadioIndex]);
  }

  Future<void> previousRadio() async {
    _currentRadioIndex = (_currentRadioIndex - 1 + _radioUrls.length) % _radioUrls.length;
    await playRadio(_radioUrls[_currentRadioIndex]);
  }

  void _showNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'radio_channel',
        title: 'Çalan Radyo',
        body: _currentUrl.contains('stream1') ? 'Sıla Yolu FM' : 'Slow',
        notificationLayout: NotificationLayout.MediaPlayer,
        largeIcon: 'https://r.resimlink.com/Dcx1mRNUA-Hd.png',
        autoDismissible: false,
        displayOnBackground: true,
        displayOnForeground: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'PREVIOUS',
          label: 'Previous',
          actionType: ActionType.KeepOnTop,
        ),
        NotificationActionButton(
          key: 'PLAY_PAUSE',
          label: _isPlaying ? 'Pause' : 'Resume',
          actionType: ActionType.KeepOnTop,
        ),
        NotificationActionButton(
          key: 'NEXT',
          label: 'Next',
          actionType: ActionType.KeepOnTop,
        ),
      ],
    );
  }

  void _dismissNotification() {
    AwesomeNotifications().dismiss(10);
  }
}
