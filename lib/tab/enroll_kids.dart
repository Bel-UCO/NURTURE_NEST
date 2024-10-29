import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/tab/dashboard.dart';
import 'dart:convert';

class EnrollKidFormPage extends StatefulWidget {
  final String kidId;

  const EnrollKidFormPage({super.key, required this.kidId});

  @override
  _EnrollKidFormPageState createState() => _EnrollKidFormPageState();
}

class _EnrollKidFormPageState extends State<EnrollKidFormPage> {
  final TextEditingController _enrollCodeController = TextEditingController();
  final TextEditingController _caretakerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  void enrollChild() async {
    // Validasi input
    if (_caretakerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Caretaker Name is required!'),
      ));
      return;
    }

    if (_enrollCodeController.text.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enroll Code must be 16 digits!'),
      ));
      return;
    }

    // Mempersiapkan data untuk dikirim
    final enrollmentData = {
      'id_kids': widget.kidId,
      'enroll_caretaker': _caretakerController.text,
      'enroll_note': _notesController.text,
      'enroll_code': _enrollCodeController.text,
    };

    // Debugging: Print JSON yang akan dikirim
    print('Enrollment Data: ${json.encode(enrollmentData)}');

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/enroll'),
      body: json.encode(enrollmentData),
      headers: {'Content-Type': 'application/json'},
    );

    // Debugging: Print status dan body respons
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enrollment successful!'),
      ));

      // Navigasi kembali ke halaman dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const DashboardTab()), // Ganti dengan halaman dashboard Anda
        (Route<dynamic> route) => false, // Menghapus semua rute sebelumnya
      );
    } else if (response.statusCode == 409) {
      // Tampilkan notifikasi jika data sudah ada
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have already been enrolled.'),
      ));
    } else {
      // Tampilkan snackbar untuk kesalahan umum
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enrollment failed!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4dfe6),
      appBar: AppBar(
        title: const Text('Enroll Kid'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enroll Code di posisi pertama
            TextField(
              controller: _enrollCodeController,
              decoration:
                  const InputDecoration(labelText: 'Enroll Code (16 digits)'),
              keyboardType:
                  TextInputType.number, // Memungkinkan input angka saja
              maxLength: 16, // Membatasi input hingga 16 digit
            ),
            const SizedBox(height: 10),
            // Caretaker Name di posisi kedua
            TextField(
              controller: _caretakerController,
              decoration: const InputDecoration(labelText: 'Caretaker Name'),
            ),
            const SizedBox(height: 10),
            // Notes di posisi terakhir
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: enrollChild,
              child: const Text('Enroll Now'),
            ),
          ],
        ),
      ),
    );
  }
}
