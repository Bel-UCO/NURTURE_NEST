import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class NotesHistoryPage extends StatelessWidget {
  final String kidID;

  const NotesHistoryPage({super.key, required this.kidID});

  Future<List<dynamic>> fetchNotes() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/notes/$kidID'));

    if (response.statusCode == 200) {
      // Menggunakan try-catch untuk menangkap kesalahan decoding
      try {
        List<dynamic> notes = json.decode(response.body);
        return notes; // Mengembalikan list catatan
      } catch (e) {
        // Jika terjadi kesalahan saat decoding, kembalikan list kosong
        return [];
      }
    } else {
      throw Exception('Failed to load notes: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFEBF1),
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: const Color(0xFFD1E8FF),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Center(
                child:
                    Text("No notes available")); // Pesan jika tidak ada catatan
          }

          // Menampilkan data
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Color(0xFF231123)),
            itemBuilder: (context, index) {
              var note = snapshot.data![index];
              // Mengonversi dan memformat tanggal
              DateTime noteDate = DateTime.parse(note['notes_date']);
              String formattedDate =
                  DateFormat('dd MMMM yyyy').format(noteDate);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal sebagai informasi utama
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF231123),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Isi catatan
                    Text(
                      note['notes'] ?? 'No notes available', // Menangani null
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF231123)),
                    ),
                    const SizedBox(height: 4),
                    // Informasi tambahan
                    Text(
                      "Caretaker: ${note['caretaker'] ?? 'Unknown'}", // Menangani null
                      style: const TextStyle(color: Color(0xFF414066)),
                    ),
                    Text(
                      "Daycare: ${note['daycare_name'] ?? 'Unknown'}", // Menangani null
                      style: const TextStyle(color: Color(0xFF414066)),
                    ),
                    // Menampilkan gambar jika ada
                    if (note['note_image'] != null &&
                        note['note_image'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.memory(
                          base64Decode(note['note_image']),
                          height:
                              100, // Sesuaikan dengan tinggi yang diinginkan
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
