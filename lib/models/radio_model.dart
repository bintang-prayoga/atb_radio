import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class RadioModel {
  final String id; // ID unik untuk setiap radio
  final String name;
  final String url;
  final String favicon;
  final String tags;

  RadioModel({
    required this.id,
    required this.name,
    required this.url,
    required this.favicon,
    required this.tags,
  });

  /// Factory method untuk membuat model dari JSON
  factory RadioModel.fromJson(Map<String, dynamic> json) {
    return RadioModel(
      id: json['stationuuid']?.toString() ?? '', // Pastikan ID tidak null
      name: const Utf8Decoder().convert(json['name'].toString().codeUnits) ?? '',
      url: json['url']?.toString() ?? '',
      favicon: json['favicon']?.toString() ?? '',
      tags: json['tags']?.toString() ?? '',
    );
  }

  /// Factory method untuk membuat model dari Firestore
  factory RadioModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // Cast data menjadi Map
    if (data == null) {
      throw Exception('Document data is null'); // Tangani jika data kosong
    }
    return RadioModel(
      id: doc.id, // Gunakan ID dokumen Firestore sebagai ID model
      name: data['name'] ?? '',
      url: data['url'] ?? '',
      favicon: data['favicon'] ?? '',
      tags: data['tags'] ?? '',
    );
  }

  /// Konversi model ke format Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'favicon': favicon,
      'tags': tags,
    };
  }
}
