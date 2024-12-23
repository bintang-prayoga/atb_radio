import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/radio_model.dart';
import '../services/radio_service.dart';

final homeViewModelProvider = ChangeNotifierProvider((ref) => HomeViewModel());

class HomeViewModel extends ChangeNotifier {
  final RadioService _radioService = RadioService();
  final List<RadioModel> _radios = <RadioModel>[];
  final List<RadioModel> _favorites = <RadioModel>[];
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');

  List<RadioModel> get radios => List.unmodifiable(_radios);
  List<RadioModel> get favorites => List.unmodifiable(_favorites);

  /// Fetch all radios from the service
  Future<void> fetchRadios() async {
    try {
      _radios.clear();
      final fetchedRadios = await _radioService.fetchRadios();
      _radios.addAll(fetchedRadios);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching radios: $e');
      throw Exception('Failed to fetch radios');
    }
  }

  /// Fetch favorites for the current user
  Future<List<RadioModel>> fetchFavorites(String userId) async {
    try {
      _favorites.clear();
      final fetchedFavorites = await _radioService.fetchFavorites(userId);
      _favorites.addAll(fetchedFavorites);
      notifyListeners();
      return List.unmodifiable(_favorites); // Pastikan daftar tidak dapat diubah
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      throw Exception('Failed to fetch favorites');
    }
  }


  /// Add a radio to favorites
  Future<void> addFavorite(String userId, RadioModel radio) async {
    try {
      await _radioService.addFavorite(userId, radio);
      if (!_favorites.any((fav) => fav.id == radio.id)) {
        _favorites.add(radio);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      throw Exception('Failed to add favorite');
    }
  }

  /// Remove a radio from favorites
  Future<void> removeFavorite(String userId, String radioId) async {
    try {
      await _radioService.removeFavorite(userId, radioId);
      _favorites.removeWhere((radio) => radio.id == radioId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      throw Exception('Failed to remove favorite');
    }
  }

  /// Search radios based on query
  List<RadioModel> searchRadios(String query) {
    if (query.isEmpty) return radios;
    final lowerQuery = query.toLowerCase();
    return radios
        .where((radio) =>
    radio.name.toLowerCase().contains(lowerQuery) ||
        radio.tags.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
