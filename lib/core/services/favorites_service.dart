import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FavoriteType { ayah, hadith, zekr }

class FavoriteItem {
  final String id; // unique identifier, e.g., ayah number or hadith id
  final FavoriteType type;
  final String title; // display title (e.g., surah name, hadith title)
  final String subtitle; // optional secondary info
  final String content; // main text/content
  final DateTime timestamp;

  FavoriteItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      id: map['id'] as String,
      type: FavoriteType.values[map['type'] as int],
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      content: map['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}

class FavoritesService extends ChangeNotifier {
  static const _key = 'favorites';
  static final FavoritesService instance = FavoritesService._internal();

  FavoritesService._internal() {
    _load().then((_) => notifyListeners()).catchError((_) {});
  }

  List<FavoriteItem> _items = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<FavoriteItem> get items => List.unmodifiable(_items);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = json.decode(jsonString);
        _items = decoded.map((e) => FavoriteItem.fromMap(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Error decoding favorites: $e');
        _items = [];
      }
    } else {
      _items = [];
    }
    _isLoaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_items.map((e) => e.toMap()).toList());
    await prefs.setString(_key, jsonString);
  }

  Future<void> toggleFavorite(FavoriteItem item) async {
    if (!_isLoaded) await _load();
    final existing = _items.indexWhere((e) => e.id == item.id && e.type == item.type);
    if (existing >= 0) {
      _items.removeAt(existing);
    } else {
      _items.add(item);
    }
    await _save();
    notifyListeners();
  }

  Future<bool> isFavorite(String id, FavoriteType type) async {
    if (!_isLoaded) await _load();
    return _items.any((e) => e.id == id && e.type == type);
  }

  Future<List<FavoriteItem>> getFavorites([FavoriteType? type]) async {
    await _load();
    notifyListeners();
    if (type != null) {
      return _items.where((e) => e.type == type).toList();
    }
    return List.unmodifiable(_items);
  }

  Future<void> removeFavorite(FavoriteItem item) async {
    if (!_isLoaded) await _load();
    _items.removeWhere((e) => e.id == item.id && e.type == item.type);
    await _save();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _items.clear();
    await _save();
    notifyListeners();
  }
}
