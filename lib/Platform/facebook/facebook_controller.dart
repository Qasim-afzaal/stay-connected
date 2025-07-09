// platform_icons_controller.dart
import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceBookController extends GetxController {
  final String platformName;
  List<Map<String, String>> icons = [];
  String selectedPlatformName = '';
  static const String _sharedPrefsKey = 'platform_icons_data';

  final List<Map<String, String>> sharedCategories = [
    {
      'title': 'Favorite',
      'icon': 'https://cdn-icons-png.flaticon.com/512/833/833472.png'
    },
    {
      'title': 'Game',
      'icon': 'https://cdn-icons-png.flaticon.com/512/1067/1067346.png'
    },
    {
      'title': 'Entertainment',
      'icon': 'https://cdn-icons-png.flaticon.com/512/597/597177.png'
    },
    {
      'title': 'Work',
      'icon': 'https://cdn-icons-png.flaticon.com/512/3595/3595455.png'
    },
  ];

  FaceBookController(this.platformName);

  @override
  void onInit() {
    super.onInit();

    loadIcons();
  }

  Future<void> loadIcons() async {
    final prefs = await SharedPreferences.getInstance();
    final allData = prefs.getString(_sharedPrefsKey);

    if (allData != null) {
      final decoded = jsonDecode(allData) as Map<String, dynamic>;
      final platformData = decoded[platformName];

      if (platformData != null) {
        icons = List<Map<String, String>>.from(platformData);
      } else {
        icons = [];
      }
    } else {
      icons = [];
    }
    update();
  }

  Future<void> addIcon(String name, String iconUrl) async {
    icons.add({'name': name, 'icon': iconUrl});
    await _saveToPrefs();
    update();
  }

  Future<void> removeIcon(int index) async {
    if (index >= 0 && index < icons.length) {
      icons.removeAt(index);
      await _saveToPrefs();
      update();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final allData = prefs.getString(_sharedPrefsKey);
    Map<String, dynamic> dataMap = {};

    if (allData != null) {
      dataMap = Map<String, dynamic>.from(jsonDecode(allData));
    }

    dataMap[platformName] = icons;
    await prefs.setString(_sharedPrefsKey, jsonEncode(dataMap));
  }
}
