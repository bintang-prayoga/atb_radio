import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../models/radio_model.dart';
import '../utilities/config.dart';

class RadioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch radios from an external API
  Future<List<RadioModel>> fetchRadios() async {
    try {
      final response = await http.get(
        Uri.parse(Config.apiUrl),
        headers: {
          HttpHeaders.acceptCharsetHeader: 'utf-8',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentEncodingHeader: 'utf-8',
          HttpHeaders.acceptEncodingHeader: 'gzip',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final List jsonResponse = json.decode(response.body) as List;
        return jsonResponse
            .map((radio) => RadioModel.fromJson(radio as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
            'Failed to fetch radios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching radios: $e');
      throw Exception('Failed to load radios');
    }
  }

  /// Fetch favorite radios for a user
  Future<List<RadioModel>> fetchFavorites(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      return snapshot.docs
          .map(RadioModel.fromFirestore)
          .toList();

    } catch (e) {
      print('Error fetching favorites: $e');
      throw Exception('Failed to fetch favorites');
    }
  }

  /// Add a radio to favorites
  Future<void> addFavorite(String userId, RadioModel radio) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(radio.id) // Use unique ID of RadioModel
          .set(radio.toFirestore());
    } catch (e) {
      print('Error adding favorite: $e');
      throw Exception('Failed to add favorite');
    }
  }

  /// Remove a radio from favorites
  Future<void> removeFavorite(String userId, String radioId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(radioId)
          .delete();
    } catch (e) {
      print('Error removing favorite: $e');
      throw Exception('Failed to remove favorite');
    }
  }
}
