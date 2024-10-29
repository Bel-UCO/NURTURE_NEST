import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/user.dart';

class RegisterChildPage extends StatefulWidget {
  const RegisterChildPage({super.key});

  @override
  _RegisterChildPageState createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _specialNeedsController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianPhoneController =
      TextEditingController();
  final TextEditingController _secGuardianNameController =
      TextEditingController();
  final TextEditingController _secGuardianPhoneController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedSex = 'M'; // Menetapkan 'M' sebagai pilihan default

  Future<void> _registerChild() async {
    String? userId =
        UserSingleton().user?.id; // Mengambil ID pengguna dari singleton
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
      return; // Jika tidak ada ID pengguna, keluar dari fungsi
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/kids'), // Endpoint API
      headers: {'Content-Type': 'application/json'}, // Set header untuk JSON
      body: json.encode({
        "user_id": userId, // ID pengguna
        'name_kids': _nameController.text, // Nama anak
        'birth_date': _birthDateController.text, // Tanggal lahir
        'sex': _selectedSex, // Jenis kelamin
        'allergies': _allergiesController.text, // Alergi
        'special_needs': _specialNeedsController.text, // Kebutuhan khusus
        'guardian_name': _guardianNameController.text, // Nama wali
        'guardian_phone': _guardianPhoneController.text, // Nomor telepon wali
        'sec_guardian_name': _secGuardianNameController.text, // Nama wali kedua
        'sec_guardian_phone':
            _secGuardianPhoneController.text, // Nomor telepon wali kedua
        'notes': _notesController.text, // Catatan tambahan
      }),
    );

    // Menangani respons dari API
    if (response.statusCode == 201) {
      Navigator.pop(context); // Kembali ke halaman sebelumnya
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anak berhasil didaftarkan!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mendaftar anak. Harap coba lagi.')),
      );
    }
  }

  String? _validatePhone(String? value) {
    // Regex untuk memvalidasi nomor telepon (hanya angka dan panjang 10-15)
    final RegExp regex = RegExp(r'^\d{10,15}$');
    if (value == null || value.isEmpty) {
      return 'Please enter the guardian\'s phone'; // Wajib diisi
    } else if (!regex.hasMatch(value)) {
      return 'Please enter a valid phone number (10-15 digits)';
    }
    return null; // Tidak ada error jika valid
  }

  String? _validateSecGuardianPhone(String? value) {
    // Validator untuk nomor telepon wali kedua (opsional)
    if (value != null && value.isNotEmpty) {
      final RegExp regex = RegExp(r'^\d{10,15}$');
      if (!regex.hasMatch(value)) {
        return 'Please enter a valid phone number (10-15 digits)';
      }
    }
    return null; // Tidak ada error jika valid atau kosong
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Tanggal awal
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // Mengonversi tanggal ke format string yang diinginkan
        _birthDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 254, 254),
      appBar: AppBar(
        title: const Text('Register Child'),
        backgroundColor: const Color(0xffded1f0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the child\'s name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  style:
                      const TextStyle(color: Color(0xFF231123)), // Warna teks
                ),
                TextFormField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Birth Date',
                    suffixIcon: Icon(Icons.calendar_today), // Ikon kalender
                  ),
                  readOnly: true, // Membuat field tidak dapat diedit langsung
                  onTap: () => _selectBirthDate(
                      context), // Memanggil fungsi saat ditekan
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the birth date';
                    }
                    return null;
                  },
                  style:
                      const TextStyle(color: Color(0xFF231123)), // Warna teks
                ),
                const Text(
                  'Sex',
                  style: TextStyle(color: Color(0xFF231123)), // Warna teks
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('M',
                            style: TextStyle(
                                color: Color(0xFF231123))), // Warna teks
                        value: 'M',
                        groupValue: _selectedSex,
                        onChanged: (value) {
                          setState(() {
                            _selectedSex = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('F',
                            style: TextStyle(
                                color: Color(0xFF231123))), // Warna teks
                        value: 'F',
                        groupValue: _selectedSex,
                        onChanged: (value) {
                          setState(() {
                            _selectedSex = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _allergiesController,
                  decoration: const InputDecoration(labelText: 'Allergies'),
                  style:
                      const TextStyle(color: Color(0xFF231123)), // Warna teks
                ),
                TextFormField(
                  controller: _specialNeedsController,
                  decoration: const InputDecoration(labelText: 'Special Needs'),
                  style:
                      const TextStyle(color: Color(0xFF231123)), // Warna teks
                ),
                TextFormField(
                  controller: _guardianNameController,
                  decoration: const InputDecoration(labelText: 'Guardian Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the guardian\'s name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  style:
                      const TextStyle(color: Color(0xFF231123)), // Warna teks
                ),
                TextFormField(
                  controller: _guardianPhoneController,
                  decoration:
                      const InputDecoration(labelText: 'Guardian Phone'),
                  validator: _validatePhone, // Wajib diisi
                  style:
                      const TextStyle(color: Color(0xFF231123)), // Warna teks
                ),
                TextFormField(
                  controller: _secGuardianNameController,
                  decoration:
                      const InputDecoration(labelText: 'Second Guardian Name'),
                  style:
                      const TextStyle(color: Color(0xFF231123)), // Warna teks
                ),
                TextFormField(
                  controller: _secGuardianPhoneController,
                  decoration:
                      const InputDecoration(labelText: 'Second Guardian Phone'),
                  validator: _validateSecGuardianPhone, // Tidak wajib
                  style:
                      const TextStyle(color: Color(0xFF231123)), // Warna teks
                ),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  style:
                      const TextStyle(color: Color(0xFF231123)), // Warna teks
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity, // Memastikan tombol penuh
                    child: ElevatedButton(
                      onPressed: (_formKey.currentState?.validate() ?? false) &&
                              _selectedSex != null // Memastikan tombol aktif
                          ? () {
                              _registerChild(); // Memanggil fungsi untuk mendaftar anak
                            }
                          : null,
                      child: const Text('Register Child'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
