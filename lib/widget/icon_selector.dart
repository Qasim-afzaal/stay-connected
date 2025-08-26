import 'package:flutter/cupertino.dart';

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

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.photo_on_rectangle,
                  color: CupertinoColors.systemBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Select Icon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Container(
            height: 400,
            width: 300,
            child: Column(
              children: [
                const Text(
                  'Choose an icon for your category',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = availableIcons[index];
                      return GestureDetector(
                        onTap: () {
                          onIconSelected(icon['path']!, icon['name']!);

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: CupertinoColors.systemGrey4,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                icon['path']!,
                                width: 32,
                                height: 32,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    CupertinoIcons.photo,
                                    size: 32,
                                    color: CupertinoColors.systemGrey,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
