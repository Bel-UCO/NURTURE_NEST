import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForumTab extends StatelessWidget {
  const ForumTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/background.jpg', // Replace with your image asset
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile.jpg'), // Replace with your profile image asset
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            const Text(
              "Ramesh Mana",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Manager",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            UserInfoExpansionTile(
              title: 'Contact Information',
              icon: Icons.contact_mail,
              children: [
                UserInfoTile(
                  title: 'Email',
                  content: 'sudeptech@gmail.com',
                  buttonText: 'Send Email',
                  onPressed: () {
                    // Action for sending email
                    print('Email button pressed');
                  },
                ),
                UserInfoTile(
                  title: 'Phone',
                  content: '99--99876-56',
                  buttonText: 'Call',
                  onPressed: () {
                    // Action for calling
                    print('Call button pressed');
                  },
                ),
              ],
            ),
            const UserInfoExpansionTile(
              title: 'About Me',
              icon: Icons.person,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'This is about me link and you can know about me in this section.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoExpansionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const UserInfoExpansionTile({super.key, 
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: ExpansionTile(
          leading: Icon(icon),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          children: children,
        ),
      ),
    );
  }
}

class UserInfoTile extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback onPressed;

  const UserInfoTile({super.key, 
    required this.title,
    required this.content,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            content,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

void main() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
  print('Current date and time: $formattedDate');
}