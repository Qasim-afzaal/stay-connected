import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final headingStyle = TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]);
    final sectionSpacing = SizedBox(height: 24);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stay Connected',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Welcome to Stay Connected',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            sectionSpacing,
            Text('About', style: headingStyle),
            const SizedBox(height: 8),
            const Text(
              'Stay Connected was designed and created for those who have family, friends, interests, curiosities, favorites, etc. in the social media world and don\'t have or want a social media account, but want to Stay Connected.',
              style: TextStyle(fontSize: 15),
            ),
            sectionSpacing,
            Text('Reduce screen time', style: headingStyle),
            const SizedBox(height: 8),
            const Text(
              'Stay Connected is also for those who want to minimize the amount of time they spend scrolling through feeds and spend more time focused on their interests.',
              style: TextStyle(fontSize: 15),
            ),
            sectionSpacing,
            Text('Connecting', style: headingStyle),
            const SizedBox(height: 8),
            const Text(
              'Stay Connected allows you to add and organize your friends/interests from the most popular social media sites in one location without needing to have a social media account or app.',
              style: TextStyle(fontSize: 15),
            ),
            sectionSpacing,
            Text('No account required', style: headingStyle),
            const SizedBox(height: 8),
            const Text(
              'Stay Connected was intentionally designed to allow the user to browse social media sites anonymously, which is why there is no user login required (and let\'s be honest, who needs another password to forget or account to be hacked!?).',
              style: TextStyle(fontSize: 15),
            ),
            sectionSpacing,
            Text('What the future holds', style: headingStyle),
            const SizedBox(height: 8),
            const Text(
              'The app was created and designed by a U.S. Army Veteran, who specialized in Cyber Security and has a huge passion for development. As we continue to grow we plan on making many updates, some of which are:',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('- iOS Version', style: TextStyle(fontSize: 15)),
                  Text('- More social media sites',
                      style: TextStyle(fontSize: 15)),
                  Text('- More category icons', style: TextStyle(fontSize: 15)),
                  Text(
                      '- Option to replace default users icons with true profile pics',
                      style: TextStyle(fontSize: 15)),
                  Text('- Ability to transfer to a new device',
                      style: TextStyle(fontSize: 15)),
                  Text(
                      '- Functional open app feature if you have the app installed',
                      style: TextStyle(fontSize: 15)),
                ],
              ),
            ),
            sectionSpacing,
            Text('Contact Us', style: headingStyle),
            const SizedBox(height: 8),
            const Text(
              'If you have any questions or suggestions to make the app better, please feel free to contact us.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'info@lets-stay-connected.com',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            sectionSpacing,
          ],
        ),
      ),
    );
  }
}
