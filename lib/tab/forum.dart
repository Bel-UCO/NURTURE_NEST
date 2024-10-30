import 'package:flutter/material.dart';
import 'chatpage.dart';

class ForumTab extends StatefulWidget {
  const ForumTab({super.key});

  @override
  _ForumTabState createState() => _ForumTabState();
}

class _ForumTabState extends State<ForumTab> {
  List<Map<String, dynamic>> users = [
    {'name': 'Dr. Blblabla', 'image': 'assets/dummy_image/notes1.png'},
    {
      'name': 'Dr. Longnamewithmorethan10characters',
      'image': 'assets/dummy_image/notes2.png'
    },
    {'name': 'Dr. Smith', 'image': 'assets/dummy_image/notes3.png'},
  ];

  List<Map<String, dynamic>> posts = []; // List untuk menyimpan post

  @override
  void initState() {
    super.initState();
    fetchPosts(); // Panggil fungsi untuk mengambil post
  }

  Future<void> fetchPosts() async {
    // Simulasikan dengan data dummy
    posts = List.generate(
        20,
        (index) => {
              'userName': 'User $index',
              'content':
                  'Ini adalah isi post ke-$index yang cukup panjang untuk ditampilkan, lebih dari dua baris.',
              'date': DateTime.now().subtract(Duration(days: index)).toString(),
              'postId': index, // ID post untuk mengambil komen
            });
    setState(() {});
  }

  void createPost(String content) {
    // TODO: Implementasi API untuk mengirim post baru
  }

  void createComment(int postId, String comment) {
    // TODO: Implementasi API untuk mengirim komentar baru
  }

  void openChat(String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(userName: userName),
      ),
    );
  }

  String formatUserName(String name) {
    return name.length > 10 ? '${name.substring(0, 10)}...' : name;
  }

  void _showReplyDialog(int postId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reply to Post'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'Type your comment here...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Kirim komentar dengan API
                createComment(postId, commentController.text);
                Navigator.of(context).pop();
              },
              child: Text('Send'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePostDialog() {
    TextEditingController postController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Post'),
          content: TextField(
            controller: postController,
            decoration: InputDecoration(hintText: 'What\'s on your mind?'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Kirim post baru dengan API
                createPost(postController.text);
                Navigator.of(context).pop();
              },
              child: Text('Post'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFE9DFF4), // Warna latar belakang
      child: Stack(
        children: [
          Column(
            children: [
              // Bagian CHAT
              SizedBox(height: 10), // Padding atas untuk chat
              Container(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'CHAT',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => openChat(users[index]['name']),
                      child: Container(
                        width: 70,
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(users[index]['image']),
                              radius: 30,
                            ),
                            SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                formatUserName(users[index]['name']),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              // Bagian FORUM
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'FORUM',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ExpansionTile(
                        title: Text(posts[index]['userName']),
                        subtitle: Text(posts[index]['date']),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  posts[index]['content'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _showReplyDialog(posts[index]['postId']);
                            },
                            child: Text('Reply'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _showCreatePostDialog,
              label: Text('POST'),
              icon: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

