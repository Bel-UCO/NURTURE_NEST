import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DaycareHistoryPage extends StatelessWidget {
  final String kidID;

  const DaycareHistoryPage({super.key, required this.kidID});

  Future<List<dynamic>> fetchDaycareHistory() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/enroll_history/$kidID'));

    if (response.statusCode == 200) {
      try {
        // Mengonversi respons menjadi list
        List<dynamic> history = json.decode(response.body);
        return history.isNotEmpty ? history : []; // Mengembalikan list kosong jika data tidak ada
      } catch (e) {
        return []; // Tangkap kesalahan decoding dan kembalikan list kosong
      }
    } else {
      throw Exception('Failed to load daycare history: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFEBF1),
      appBar: AppBar(
        title: const Text('Daycare History'),
        backgroundColor: const Color(0xFFD1E8FF),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchDaycareHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("There's no daycare history yet")); // Pesan jika tidak ada riwayat daycare
          }

          // Menampilkan data
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFF231123)),
            itemBuilder: (context, index) {
              var daycare = snapshot.data![index];
              // Mengonversi dan memformat tanggal
              DateTime enrollDate = DateTime.parse(daycare['enroll_date']);
              String formattedDate = DateFormat('dd MMMM yyyy').format(enrollDate);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal sebagai informasi utama
                    Text(
                      formattedDate, // Tanggal diformat
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF231123),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Informasi daycare
                    Text(
                      "Daycare: ${daycare['name_daycare'] ?? 'Unknown'}", // Menangani null
                      style: const TextStyle(fontSize: 16, color: Color(0xFF231123)),
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
