import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String userName;

  const ChatPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // Data dummy percakapan
    List<Map<String, String>> messages = [
      {'sender': 'user', 'message': 'Halo Dr. $userName!'},
      {'sender': 'doctor', 'message': 'Halo! Ada yang bisa saya bantu?'},
      {'sender': 'user', 'message': 'Saya merasa kurang sehat belakangan ini.'},
      {'sender': 'doctor', 'message': 'Sudah berapa lama Anda merasakannya?'},
      {'sender': 'user', 'message': 'Sekitar seminggu.'},
      {'sender': 'doctor', 'message': 'Apakah ada gejala khusus?'},
      {'sender': 'user', 'message': 'Sakit kepala dan sedikit demam.'},
      {'sender': 'doctor', 'message': 'Baik, sebaiknya Anda periksa lebih lanjut.'},
      {'sender': 'user', 'message': 'Terima kasih atas sarannya!'},
      {'sender': 'doctor', 'message': 'Sama-sama! Jangan ragu untuk bertanya.'},
      // Tambahkan lebih banyak pesan sesuai kebutuhan
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $userName'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Align(
                    alignment: messages[index]['sender'] == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: messages[index]['sender'] == 'user'
                            ? Colors.blue[100]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        messages[index]['message']!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // TODO: Kirim pesan
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
