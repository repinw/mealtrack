import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyInventory = 'inventory_data';

  Future<void> saveItems(List<FridgeItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = items
        .map((item) => item.toJson())
        .toList();
    final String jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyInventory, jsonString);
  }

  Future<List<FridgeItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
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
}
