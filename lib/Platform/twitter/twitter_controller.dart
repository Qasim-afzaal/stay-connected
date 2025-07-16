// twitter_controller.dart
import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwitterController extends GetxController {
  final String platformName;
  List<Map<String, String>> icons = [];
  String selectedPlatformName = '';
  static const String _sharedPrefsKey = 'platform_icons_data';

  final List<Map<String, String>> sharedCategories = [
    {
      'title': 'Favorite',
      'icon': 'assets/icons/home.svg'
    },
    {
      'title': 'Game',
      'icon': 'assets/icons/chat.svg'
    },
    {
      'title': 'Entertainment',
      'icon': 'assets/icons/settings.svg'
    },
    {
      'title': 'Work',
      'icon': 'assets/icons/account_circle.svg'
    },
  ];

  TwitterController(this.platformName);

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