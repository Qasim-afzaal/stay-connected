import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconSelector extends StatelessWidget {
  final Function(String iconPath, String iconName) onIconSelected;

  const IconSelector({
    super.key,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showIconSelectorDialog(context);
    });

    return Container();
  }

  void _showIconSelectorDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final List<Map<String, String>> availableIcons = [
      {'name': 'Add', 'path': 'assets/images/platform_icons/add.png'},
      {'name': 'Food', 'path': 'assets/images/platform_icons/img_food_12.png'},
      {'name': 'Health', 'path': 'assets/images/platform_icons/health.png'},
      {
        'name': 'Photos',
        'path': 'assets/images/platform_icons/img_photo_1.png'
      },
      {'name': 'Music', 'path': 'assets/images/platform_icons/img_music_1.png'},
      {'name': 'Pets', 'path': 'assets/images/platform_icons/img_pets_1.png'},
      {
        'name': 'Games',
        'path': 'assets/images/platform_icons/img_gamepad_1.png'
      },
      {
        'name': 'Entertainment',
        'path': 'assets/images/platform_icons/ic_entertainment.png'
      },
      {'name': 'Auto', 'path': 'assets/images/platform_icons/auto.png'},
      {'name': 'Fashion', 'path': 'assets/images/platform_icons/fashion.png'},
      {
        'name': 'Desserts',
        'path': 'assets/images/platform_icons/img_desserts_1_64x64.png'
      },
      {
        'name': 'Favorites',
        'path': 'assets/images/platform_icons/img_favorite_1.png'
      },
      {
        'name': 'Fitness',
        'path': 'assets/images/platform_icons/img_fitness_1.png'
      },
      {
        'name': 'Travel',
        'path': 'assets/images/platform_icons/img_travel_1.png'
      },
      {'name': 'News', 'path': 'assets/images/platform_icons/news.png'},

      // Custom Icons
      {'name': 'Cupid', 'path': 'assets/images/custom_icons/cupid_1.png'},
      {'name': 'Garden', 'path': 'assets/images/custom_icons/garden_3.png'},
      {'name': 'Heart', 'path': 'assets/images/custom_icons/heart_2.png'},
      {'name': 'Heart 2', 'path': 'assets/images/custom_icons/heart_3.png'},
      {
        'name': 'Lifestyle',
        'path': 'assets/images/custom_icons/lifestyle_1.png'
      },
      {'name': 'Plane', 'path': 'assets/images/custom_icons/plane_5.png'},
      {'name': 'Recipe', 'path': 'assets/images/custom_icons/recipe_3.png'},
      {
        'name': 'Recipe Book',
        'path': 'assets/images/custom_icons/recipe_book.png'
      },
      {'name': 'Reel', 'path': 'assets/images/custom_icons/reel_2.png'},
      {'name': 'Rest', 'path': 'assets/images/custom_icons/rest_2.png'},
      {'name': 'Rest 2', 'path': 'assets/images/custom_icons/rest_3.png'},
      {'name': 'Tele', 'path': 'assets/images/custom_icons/tele_1.png'},
      {
        'name': 'Checkmark',
        'path': 'assets/images/custom_icons/checkmark_blue.png'
      },
      {
        'name': 'Blue Apron',
        'path': 'assets/images/custom_icons/blue_apron.png'
      },
      {'name': 'Circle', 'path': 'assets/images/custom_icons/circle_2.png'},
      {'name': 'Play', 'path': 'assets/images/custom_icons/play.png'},
      {'name': 'Circle 2', 'path': 'assets/images/custom_icons/circle.png'},
      {'name': 'Square', 'path': 'assets/images/custom_icons/square.png'},
      {'name': 'Money', 'path': 'assets/images/custom_icons/money.png'},
      {'name': 'Twitter', 'path': 'assets/images/custom_icons/twitter.png'},
      {'name': 'Tick Mark', 'path': 'assets/images/custom_icons/tick_mark.png'},
      {'name': 'Folder', 'path': 'assets/images/custom_icons/folder.png'},
      {'name': 'Correct', 'path': 'assets/images/custom_icons/correct.png'},
      {
        'name': 'Egg Decoration',
        'path': 'assets/images/custom_icons/egg_decoration.png'
      },
      {
        'name': 'Easter Egg',
        'path': 'assets/images/custom_icons/easter_egg.png'
      },
      {
        'name': 'Easter Day',
        'path': 'assets/images/custom_icons/easter_day.png'
      },
      {
        'name': 'Electric Kettle',
        'path': 'assets/images/custom_icons/electric_kettle.png'
      },
      {'name': 'Necklace', 'path': 'assets/images/custom_icons/necklace.png'},
      {
        'name': 'Viennese Coffee',
        'path': 'assets/images/custom_icons/viennese_coffee.png'
      },
      {'name': 'Dislike', 'path': 'assets/images/custom_icons/dislike.png'},
      {
        'name': 'Favorite Chart',
        'path': 'assets/images/custom_icons/favorite_chart.png'
      },
      {'name': 'Koran', 'path': 'assets/images/custom_icons/koran.png'},
      {'name': 'Pets', 'path': 'assets/images/custom_icons/img_pets_12.png'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Update Icon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Icon Grid
                  SizedBox(
                    height: 300,
                    width: 280,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: availableIcons.length,
                      itemBuilder: (context, index) {
                        final icon = availableIcons[index];
                        return GestureDetector(
                          onTap: () {
                            onIconSelected(icon['path']!, icon['name']!);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Image.asset(
                                icon['path']!,
                                width: 32,
                                height: 32,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    CupertinoIcons.photo,
                                    size: 32,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
