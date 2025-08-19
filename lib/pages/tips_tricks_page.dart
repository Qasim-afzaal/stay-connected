import 'package:flutter/material.dart';

class TipsTricksPage extends StatelessWidget {
  const TipsTricksPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Tips and Tricks',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Apps',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'The social media apps do not need to be installed on your device in order too...Stay Connected.',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 20),
              Text(
                'Performance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Having an account with the sites below is not needed, but may provide a better experience while using Stay Connected.',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('- Facebook', style: TextStyle(fontSize: 15)),
                    Text('- Instagram', style: TextStyle(fontSize: 15)),
                    Text('- X (Formely Twitter)',
                        style: TextStyle(fontSize: 15)),
                    Text('- Reddit (to view NSFW tags)',
                        style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Open app button',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Currently we have the Open app function disabled (planned future update to enable). If you do have an account you are still able to log in for full functionality.',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: Image.asset(
                  'assets/images/gram_tt.JPG',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Add to Album and Rename',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'A long press on a user will give you two options:',
                style: TextStyle(fontSize: 15),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. Add to Album', style: TextStyle(fontSize: 15)),
                    Text('2. Rename', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: Image.asset(
                  'assets/images/lp_sc.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Some added users (profiles) will come in with a generic name of (r). A long press will allow you to rename the user (profile). The rename function can be used at any time on any user (profile).',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: Image.asset(
                  'assets/images/r_edit.JPG',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: Image.asset(
                  'assets/images/rename_sc.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
