import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/user.dart';
import 'package:myapp/login.dart';
import 'package:myapp/tab/profile/register_child.dart';
import 'package:myapp/tab/profile/notes_history.dart';
import 'package:myapp/tab/profile/daycare_history.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  List<Kid> kids = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKids();
  }

  Future<void> _fetchKids() async {
    String? userId = UserSingleton().user?.id;
    if (userId == null) return;

    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/kids/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        kids = data.map((json) => Kid.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load kids: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    String? name = UserSingleton().user?.name;

    return Scaffold(
      backgroundColor: const Color(0xffF3F2FB),
      appBar: AppBar(
        title: Text(name ?? 'User not logged in',
            style: const TextStyle(color: Color(0xFF231123))),
        backgroundColor: const Color(0xffded1f0),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF231123)),
            onPressed: () {
              _showSettings(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: Colors.pink[100],
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "KIDS",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF231123),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Check if empty
                      if (kids.isEmpty)
                        const Text(
                          "There's no kid in the list",
                          style:
                              TextStyle(fontSize: 16, color: Color(0xFF231123)),
                          textAlign: TextAlign.center,
                        )
                      else
                        // Show expansion tile
                        ...kids.map((kid) {
                          return ExpansionTile(
                            title: Text(
                              kid.name,
                              style: const TextStyle(color: Color(0xFF231123)),
                            ),
                            children: [
                              ListTile(
                                title: Text("Birth Date: ${kid.birthDate}",
                                    style: const TextStyle(
                                        color: Color(0xFF231123))),
                              ),
                              ListTile(
                                title: Text("Sex: ${kid.sex}",
                                    style: const TextStyle(
                                        color: Color(0xFF231123))),
                              ),
                              ListTile(
                                title: Text("Allergies: ${kid.allergies}",
                                    style: const TextStyle(
                                        color: Color(0xFF231123))),
                              ),
                              ListTile(
                                title: Text(
                                    "Special Needs: ${kid.specialNeeds}",
                                    style: const TextStyle(
                                        color: Color(0xFF231123))),
                              ),
                              ListTile(
                                title: Text(
                                    "Guardian Name: ${kid.guardianName}",
                                    style: const TextStyle(
                                        color: Color(0xFF231123))),
                              ),
                              ListTile(
                                title: Text(
                                    "Guardian Phone: ${kid.guardianPhone}",
                                    style: const TextStyle(
                                        color: Color(0xFF231123))),
                              ),
                              ListTile(
                                title: Text(
                                    "Second Guardian Name: ${kid.secGuardianName}",
                                    style: const TextStyle(
                                        color: Color(0xFF231123))),
                              ),
                              ListTile(
                                title: Text(
                                    "Second Guardian Phone: ${kid.secGuardianPhone}",
                                    style: const TextStyle(
                                        color: Color(0xFF231123))),
                              ),
                              ListTile(
                                title: Text("Notes: ${kid.notes}",
                                    style: const TextStyle(
                                        color: Color(0xFF231123))),
                              ),
                              // Add the navigation buttons
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Debug log untuk memastikan idKids tidak null
                                        print(
                                            'Navigating to NotesHistoryPage with kidId: ${kid.idKids}');

                                        // Navigate to Notes History page
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NotesHistoryPage(
                                                    kidID: kid
                                                        .idKids), // Pastikan ini
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFD2FDFF)),
                                      child: const Text("Notes History"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Debug log untuk memastikan idKids tidak null
                                        print(
                                            'Navigating to NotesHistoryPage with kidId: ${kid.idKids}');

                                        // Navigate to Notes History page
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DaycareHistoryPage(
                                                    kidID: kid
                                                        .idKids), // Pastikan ini
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFD2FDFF)),
                                      child: const Text("Daycare History"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),

                      const SizedBox(height: 10), // Jarak sebelum garis
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0), // Jarak 2px dari pinggir
                        child: Divider(
                            thickness: 1, color: Color(0xFF231123)), // Garis
                      ),
                      const SizedBox(height: 5), // Jarak setelah garis
                      ElevatedButton(
                        onPressed: () {
                          // Navigasi ke halaman pendaftaran anak
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RegisterChildPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA2B6DF),
                          padding: const EdgeInsets.all(2),
                          shape: const CircleBorder(),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings',
              style: TextStyle(color: Color(0xFF231123))),
          content: const Text('This is where your settings would go.',
              style: TextStyle(color: Color(0xFF231123))),
          actions: <Widget>[
            TextButton(
              child: const Text('Logout',
                  style: TextStyle(color: Color(0xFF231123))),
              onPressed: () {
                UserSingleton().logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            TextButton(
              child: const Text('Close',
                  style: TextStyle(color: Color(0xFF231123))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Kid {
  final String idKids; // ID anak
  final String name;
  final String birthDate;
  final String sex;
  final String allergies;
  final String specialNeeds;
  final String guardianName;
  final String guardianPhone;
  final String secGuardianName;
  final String secGuardianPhone;
  final String notes;

  Kid({
    required this.idKids,
    required this.name,
    required this.birthDate,
    required this.sex,
    required this.allergies,
    required this.specialNeeds,
    required this.guardianName,
    required this.guardianPhone,
    required this.secGuardianName,
    required this.secGuardianPhone,
    required this.notes,
  });

  factory Kid.fromJson(Map<String, dynamic> json) {
    return Kid(
      idKids: json['id_kids'], // Pastikan ID anak diambil dari JSON
      name: json['name_kids'],
      birthDate: json['birth_date'],
      sex: json['sex'],
      allergies: json['allergies'],
      specialNeeds: json['special_needs'],
      guardianName: json['guardian_name'],
      guardianPhone: json['guardian_phone'],
      secGuardianName: json['sec_guardian_name'],
      secGuardianPhone: json['sec_guardian_phone'],
      notes: json['notes'],
    );
  }
}
