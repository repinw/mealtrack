import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mealtrack/core/exceptions/storage_exception.dart';
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
  return LocalStorageService(ref.watch(sharedPreferencesProvider.future));
}

class LocalStorageService {
  final Future<SharedPreferences> _prefs;
  static const String _keyInventory = 'inventory_data';

  LocalStorageService(this._prefs);

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

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupKey = '${_keyInventory}_corrupt_$timestamp';
      await prefs.setString(backupKey, jsonString);
      debugPrint('Backed up corrupt inventory to $backupKey');

      throw StorageException('Failed to parse inventory data', e);
    }
  }

  Future<void> deleteAllItems() async {
    final prefs = await _prefs;
    await prefs.remove(_keyInventory);
  }
}
