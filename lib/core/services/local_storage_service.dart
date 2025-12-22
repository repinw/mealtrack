import 'dart:convert';
import 'package:mealtrack/core/models/fridge_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyInventory = 'inventory_data';

  // Save List to Disk
  Future<void> saveItems(List<FridgeItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Convert List<Object> to List<Map>
    final List<Map<String, dynamic>> jsonList = items
        .map((item) => item.toJson())
        .toList();
    // 2. Convert List<Map> to JSON String
    final String jsonString = jsonEncode(jsonList);
    // 3. Save String
    await prefs.setString(_keyInventory, jsonString);
  }

  // Load List from Disk
  Future<List<FridgeItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyInventory);

    if (jsonString == null) return [];

    try {
      // 1. Decode String to List<dynamic>
      final List<dynamic> decodedList = jsonDecode(jsonString);
      // 2. Convert List<dynamic> to List<FridgeItem>
      return decodedList.map((e) => FridgeItem.fromJson(e)).toList();
    } catch (e) {
      print('Error loading inventory: $e');
      return [];
    }
  }
}
