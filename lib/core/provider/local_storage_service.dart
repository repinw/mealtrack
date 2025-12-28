import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'local_storage_service.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
LocalStorageService localStorageService(Ref ref) {
  return LocalStorageService(ref);
}

class LocalStorageService {
  final Ref _ref;
  static const String _keyInventory = 'inventory_data';

  LocalStorageService(this._ref);

  Future<SharedPreferences> get _prefs =>
      _ref.read(sharedPreferencesProvider.future);

  Future<void> saveItems(List<FridgeItem> items) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> jsonList = items
        .map((item) => item.toJson())
        .toList();
    final String jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyInventory, jsonString);
  }

  Future<List<FridgeItem>> loadItems() async {
    final prefs = await _prefs;
    final String? jsonString = prefs.getString(_keyInventory);

    if (jsonString == null) return [];

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map((e) => FridgeItem.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error loading inventory: $e');
      rethrow;
    }
  }

  Future<void> deleteAllItems() async {
    final prefs = await _prefs;
    await prefs.remove(_keyInventory);
  }
}
