import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../utilities/config.dart';

final radioTileViewModelProvider = ChangeNotifierProvider(
      (ref) => RadioTileViewModel(),
);

class RadioTileViewModel extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final configState = Config();

  Timer? _sleepTimer; // Tambahkan Timer untuk Sleep Timer

  RadioTileViewModel() {
    _player.playerStateStream.listen(_updateState);
  }

  bool get playing => _player.playing;
  bool get paused =>
      _player.playerState.processingState == ProcessingState.ready &&
          !_player.playing;
  bool get sleepTimerActive => _sleepTimer != null; // Status Sleep Timer

  Future<void> play(String url) async {
    await _player.setUrl(url);
    await _player.setPreferredPeakBitRate(configState.audioBitrate.toDouble());
    await _player.play();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    _cancelSleepTimer(); // Batalkan Sleep Timer jika ada
  }

  // Fungsi untuk mengatur Sleep Timer
  void setSleepTimer(Duration duration) {
    _cancelSleepTimer(); // Batalkan Timer sebelumnya jika ada
    _sleepTimer = Timer(duration, () async {
      await stop(); // Hentikan pemutar radio
      _sleepTimer = null; // Reset Timer
      notifyListeners(); // Update UI
    });
    notifyListeners(); // Update UI
  }

  // Batalkan Sleep Timer
  void cancelSleepTimer() {
    _cancelSleepTimer();
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    notifyListeners();
  }

  void _updateState(PlayerState playerState) {
    notifyListeners();
  }

  // Firestore Integration for Favorites
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Toggle Favorite
  Future<void> toggleFavorite(String name, String url, String favicon, String tags) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favoritesRef =
    _firestore.collection('users').doc(user.uid).collection('favorites');

    final doc = await favoritesRef.doc(name).get();

    if (doc.exists) {
      // Remove from favorites
      await favoritesRef.doc(name).delete();
    } else {
      // Add to favorites
      await favoritesRef.doc(name).set({
        'name': name,
        'url': url,
        'favicon': favicon,
        'tags': tags,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }

    notifyListeners();
  }

  // Check if the radio station is a favorite
  Future<bool> isFavorite(String name) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(name)
        .get();

    return doc.exists;
  }
}
