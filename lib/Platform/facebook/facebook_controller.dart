import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stay_connected/Platform/facebook/facebook_controller.dart';
import 'package:stay_connected/Platform/facebook/facebook_controller.dart';
import 'package:stay_connected/Platform/youtube/youtube_controller.dart';
import 'package:stay_connected/Platform/youtube/youtube_controller.dart';

class FaceBookController extends GetxController {
  final String platformName;
  List<Map<String, String>> icons = [];
  bool isDeleteMode = false;
  Set<int> selectedIcons = {};

  // Platform-specific SharedPreferences key
  String get _sharedPrefsKey => 'platform_icons_${platformName.toLowerCase()}';

  FaceBookController(this.platformName);

  @override
  void onInit() {
    super.onInit();
    loadIcons();
  }

  @override
  void onClose() {
    // Save data when controller is disposed
    _saveToPrefs();
    super.onClose();
  }

  // Clear existing corrupted data only when needed
  Future<void> _clearExistingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sharedPrefsKey);
      print('Cleared corrupted data for $platformName');
    } catch (e) {
      print('Error clearing data for $platformName: $e');
    }
  }

  Future<void> loadIcons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('Facebook - Using SharedPreferences key: $_sharedPrefsKey');
      final platformData = prefs.getString(_sharedPrefsKey);

      if (platformData != null && platformData.isNotEmpty) {
        print('Facebook - Loading data: $platformData');
        final decoded = jsonDecode(platformData) as List<dynamic>;
        icons = decoded.map((item) {
          if (item is Map) {
            return {
              'name': item['name']?.toString() ?? '',
              'icon': item['icon']?.toString() ?? '',
              'category': item['category']?.toString() ?? '',
              'profileUrl': item['profileUrl']?.toString() ?? '',
            };
          } else {
            return {'name': '', 'icon': '', 'category': '', 'profileUrl': ''};
          }
        }).toList();

        // Filter out invalid entries
        icons = icons
            .where(
                (icon) => icon['name']!.isNotEmpty && icon['icon']!.isNotEmpty)
            .toList();

        print('Facebook - Loaded ${icons.length} icons');
        for (var icon in icons) {
          print(
              'Facebook - Loaded icon: ${icon['name']}, Category: ${icon['category']}, ProfileUrl: ${icon['profileUrl']}');
        }
      } else {
        // Initialize with default icons if no data exists for this platform
        icons = _getDefaultIcons();
        await _saveToPrefs(); // Save default icons
      }
    } catch (e) {
      print('Error loading icons for $platformName: $e');
      // Fallback to default icons if there's an error
      icons = _getDefaultIcons();
    }
    update();
  }

  List<Map<String, String>> _getDefaultIcons() {
    return [
      {
        'name': 'Favorites',
        'icon': 'assets/images/platform_icons/img_favorite_1.png',
        'category': 'Favorites'
      },
      {
        'name': 'Games',
        'icon': 'assets/images/platform_icons/img_gamepad_1.png',
        'category': 'Games'
      },
      {
        'name': 'Music',
        'icon': 'assets/images/platform_icons/img_music_1.png',
        'category': 'Music'
      },
      {
        'name': 'Gym',
        'icon': 'assets/images/platform_icons/img_fitness_1.png',
        'category': 'Gym'
      },
      {
        'name': 'Photos',
        'icon': 'assets/images/platform_icons/img_photo_1.png',
        'category': 'Photos'
      },
      {
        'name': 'Pets',
        'icon': 'assets/images/platform_icons/img_pets_1.png',
        'category': 'Pets'
      },
      {
        'name': 'Travel',
        'icon': 'assets/images/platform_icons/img_travel_1.png',
        'category': 'Travel'
      },
      {
        'name': 'Desserts',
        'icon': 'assets/images/platform_icons/img_desserts_1_64x64.png',
        'category': 'Desserts'
      },
      {
        'name': 'Food',
        'icon': 'assets/images/platform_icons/img_food_12.png',
        'category': 'Food'
      },
      {
        'name': 'Auto',
        'icon': 'assets/images/platform_icons/auto.png',
        'category': 'Audio'
      },
      {
        'name': 'Celebrity',
        'icon': 'assets/images/img_celebrities_1.png',
        'category': 'Celebrity'
      },
      {
        'name': 'Fashion',
        'icon': 'assets/images/platform_icons/fashion.png',
        'category': 'Fashion'
      },
      {
        'name': 'News',
        'icon': 'assets/images/platform_icons/news.png',
        'category': 'News'
      },
      {
        'name': 'Health',
        'icon': 'assets/images/platform_icons/health.png',
        'category': 'Health'
      },
      {
        'name': 'Ent',
        'icon': 'assets/images/platform_icons/ic_entertainment.png',
        'category': 'Entertainment'
      },
    ];
  }

  void toggleDeleteMode() {
    isDeleteMode = !isDeleteMode;
    if (!isDeleteMode) {
      selectedIcons.clear();
    }
    update();
  }

  void toggleIconSelection(int index) {
    if (selectedIcons.contains(index)) {
      selectedIcons.remove(index);
    } else {
      selectedIcons.add(index);
    }
    update();
  }

  void deleteSelectedIcons() async {
    try {
      // Sort indices in descending order to avoid index shifting issues
      final sortedIndices = selectedIcons.toList()
        ..sort((a, b) => b.compareTo(a));

      for (int index in sortedIndices) {
        if (index >= 0 && index < icons.length) {
          icons.removeAt(index);
        }
      }

      selectedIcons.clear();
      isDeleteMode = false;
      await _saveToPrefs();
      update();
    } catch (e) {
      print('Error deleting icons for $platformName: $e');
    }
  }

  Future<void> addIcon(String name, String iconUrl, {String? category}) async {
    try {
      icons.add(
          {'name': name, 'icon': iconUrl, 'category': category ?? 'General'});
      await _saveToPrefs();
      update();
    } catch (e) {
      print('Error adding icon for $platformName: $e');
    }
  }

  Future<void> addFriendToCategory(
      String friendName, String category, String profileUrl) async {
    try {
      icons.add({
        'name': friendName,
        'icon': 'assets/icons/account_circle.svg',
        'category': category,
        'profileUrl': profileUrl,
      });
      await _saveToPrefs();
      update();
    } catch (e) {
      print('Error adding friend to category for $platformName: $e');
    }
  }

  Future<void> removeIcon(int index) async {
    try {
      if (index >= 0 && index < icons.length) {
        icons.removeAt(index);
        await _saveToPrefs();
        update();
      }
    } catch (e) {
      print('Error removing icon for $platformName: $e');
    }
  }

  Future<void> renameIcon(int index, String newName) async {
    try {
      if (index >= 0 && index < icons.length) {
        icons[index]['name'] = newName;
        await _saveToPrefs();
        update();
      }
    } catch (e) {
      print('Error renaming icon for $platformName: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sharedPrefsKey, jsonEncode(icons));
    } catch (e) {
      print('Error saving icons for $platformName: $e');
    }
  }

  Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sharedPrefsKey, jsonEncode(icons));
    } catch (e) {
      print('Error saving icons for $platformName: $e');
    }
  }
}
