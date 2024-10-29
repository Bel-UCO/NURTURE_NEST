import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/user.dart';
import 'package:myapp/tab/enroll_kids.dart';

class Child {
  final String id;
  final String name;

  Child({required this.id, required this.name});
}

class EnrollmentDetails {
  final String idKids;
  final String enrollDate;
  final String enrollCaretaker;
  final String daycareName;
  final String checkoutTime;
  final String checkoutCaretaker;
  final String food;
  final String foodCaretaker;
  final String snack;
  final String sleep;
  final String assignment;
  final String assignmentCaretaker;
  final String medicine;
  final String medicineCaretaker;
  final String enrollNote;
  final String mood;

  EnrollmentDetails({
    required this.idKids,
    required this.enrollDate,
    required this.enrollCaretaker,
    required this.daycareName,
    required this.checkoutTime,
    required this.checkoutCaretaker,
    required this.food,
    required this.foodCaretaker,
    required this.snack,
    required this.sleep,
    required this.assignment,
    required this.assignmentCaretaker,
    required this.medicine,
    required this.medicineCaretaker,
    required this.enrollNote,
    required this.mood,
  });

  factory EnrollmentDetails.fromJson(Map<String, dynamic> json) {
    return EnrollmentDetails(
      idKids: json['id_kids'] ?? '',
      enrollDate: json['enroll_date'] ?? '',
      enrollCaretaker: json['enroll_caretaker'] ?? '',
      daycareName: json['name_daycare'] ?? '',
      checkoutTime: json['checkout_time'] ?? '',
      checkoutCaretaker: json['checkout_caretaker'] ?? '',
      food: json['food'] ?? '',
      foodCaretaker: json['food_caretaker'] ?? '',
      snack: json['snack'] ?? '',
      sleep: json['sleep'] ?? '',
      assignment: json['assignment'] ?? '',
      assignmentCaretaker: json['assignment_caretaker'] ?? '',
      medicine: json['medicine'] ?? '',
      medicineCaretaker: json['medicine_caretaker'] ?? '',
      enrollNote: json['enroll_note'] ?? '',
      mood: json['mood'] ?? '',
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String? selectedKid;
  List<Child> children = [];
  EnrollmentDetails? selectedDetails;
  List<dynamic> notesToday = []; // Variabel untuk menyimpan catatan hari ini

  final List<Map<String, dynamic>> items = [
    {'title': 'Check-In', 'icon': Icons.login},
    {'title': 'Mood', 'icon': Icons.emoji_emotions},
    {'title': 'Food', 'icon': Icons.fastfood},
    {'title': 'Snack', 'icon': Icons.cake},
    {'title': 'Sleep', 'icon': Icons.bed},
    {'title': 'Medicine', 'icon': Icons.medical_services},
    {'title': 'Assignment', 'icon': Icons.assignment},
    {'title': 'Checkout', 'icon': Icons.exit_to_app},
    {'title': 'Notes', 'icon': Icons.notes},
  ];

  final List<Color> pastelColors = [
    const Color(0xFFFFC0CB),
    const Color(0xFFFFE0B2),
    const Color(0xFFFFF9B1),
    const Color(0xFFD1E7DD),
    const Color(0xFFB3E5FC),
    const Color(0xFFD1C4E9),
    const Color(0xFFD5AAFF),
  ];

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    final userSingleton = UserSingleton();
    if (userSingleton.user != null) {
      final response = await http.get(
          Uri.parse('http://10.0.2.2:3000/kids/${userSingleton.user!.id}'));
      print(
          'Fetching children for user ID: ${userSingleton.user!.id}'); // Debugging line
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        print('Children fetched: $jsonResponse'); // Debugging line
        setState(() {
          children = jsonResponse
              .map((child) =>
                  Child(id: child['id_kids'], name: child['name_kids']))
              .toList();
        });
      } else {
        print(
            'Failed to fetch children: ${response.statusCode}'); // Debugging line
      }
    }
  }

  Future<void> fetchEnrollmentDetails(String childId) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print(
        'Fetching enrollment details for child ID: $childId'); // Debugging line
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:3000/enroll_history_today/$childId'));

      if (response.statusCode == 200) {
        print('Response body: ${response.body}'); // Debugging line
        if (response.body.isEmpty || response.body == 'null') {
          setState(() {
            selectedDetails = null;
          });
          print('No enrollment details found.'); // Debugging line
          return;
        }

        List jsonResponse = json.decode(response.body);
        print('Full JSON Response: $jsonResponse'); // Debugging line

        if (jsonResponse.isNotEmpty) {
          var todayEnrollments = jsonResponse.where((data) {
            return data['enroll_date'] != null &&
                data['enroll_date'].startsWith(today);
          }).toList();

          if (todayEnrollments.isNotEmpty) {
            var data = todayEnrollments[0];
            print('Today\'s enrollment details: $data'); // Debugging line
            setState(() {
              selectedDetails = EnrollmentDetails.fromJson(data);
              fetchNotesToday(
                  childId); // Ambil catatan hari ini setelah mendapatkan detail enroll
            });
          } else {
            print('No enrollments found for today.'); // Debugging line
            setState(() {
              selectedDetails = null;
            });
          }
        } else {
          print('No enrollments found in response.'); // Debugging line
          setState(() {
            selectedDetails = null;
          });
        }
      } else {
        print(
            'Failed to load enrollment details: ${response.statusCode}'); // Debugging line
        setState(() {
          selectedDetails = null;
        });
      }
    } catch (e) {
      print('Error fetching enrollment details: $e'); // Debugging line
      setState(() {
        selectedDetails = null;
      });
    }
  }

  Future<void> fetchNotesToday(String childId) async {
    print('Fetching notes for child ID: $childId'); // Debugging line
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/notes_today/$childId'));

    if (response.statusCode == 200) {
      print('Response body for notes: ${response.body}'); // Debugging line
// Cek apakah body tidak null dan bukan 'null'
      if (response.body != 'null') {
        try {
// Jika respons valid, decode ke List<dynamic>
          List<dynamic> notes = json.decode(response.body) as List<dynamic>;
          print('Notes fetched: $notes'); // Debugging line
          setState(() {
            notesToday = notes; // Simpan hasil catatan hari ini
          });
        } catch (e) {
          print('Error decoding notes: $e'); // Debugging line
          setState(() {
            notesToday = []; // Set ke list kosong jika terjadi error
          });
        }
      } else {
        print('No notes available for today.'); // Debugging line
        setState(() {
          notesToday = []; // Set ke list kosong jika tidak ada catatan
        });
      }
    } else {
      print('Failed to fetch notes: ${response.statusCode}'); // Debugging line
      setState(() {
        notesToday = []; // Set ke list kosong jika status code tidak 200
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4dfe6),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 126, 142, 198),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedKid,
                    hint: const Text(
                      "Kid's Name",
                      style: TextStyle(color: Colors.white),
                    ),
                    isExpanded: true,
                    dropdownColor: const Color(0xFF5C6B9F),
                    items: children.map((Child kid) {
                      return DropdownMenuItem<String>(
                        value: kid.id,
                        child: Text(
                          kid.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      print('Selected kid: $value'); // Debugging line
                      setState(() {
                        selectedKid = value;
                        if (value != null) {
                          fetchEnrollmentDetails(value);
                        } else {
                          selectedDetails = null;
                          notesToday =
                              []; // Reset catatan hari ini jika tidak ada anak yang dipilih
                        }
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selectedDetails == null)
                        ElevatedButton(
                          onPressed: () {
                            if (selectedKid != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EnrollKidFormPage(kidId: selectedKid!),
                                ),
                              ).then((_) {
                                fetchEnrollmentDetails(selectedKid!);
                              });
                            }
                          },
                          child: const Text('Enroll Now'),
                        )
                      else
                        Text(
                          selectedDetails!.daycareName,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      Text(
                        DateFormat('dd MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  if (selectedDetails == null)
                    const Text(
                      'Belum enroll untuk hari ini.',
                      style: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  String title = items[index]['title'];
                  IconData icon = items[index]['icon'];
                  String notes = 'No details available.'; // Default notes value

                  if (selectedDetails != null) {
                    switch (title) {
                      case 'Check-In':
                        notes = selectedDetails!.enrollDate.isNotEmpty
                            ? 'Check-In Time: ${selectedDetails!.enrollDate}\nCaretaker: ${selectedDetails!.enrollCaretaker}'
                            : 'No check-in details';
                        print('Check-In notes: $notes'); // Debugging line
                        break;
                      case 'Mood':
                        notes = selectedDetails!.mood.isNotEmpty
                            ? 'Mood: ${selectedDetails!.mood}'
                            : 'No mood details';
                        print('Mood notes: $notes'); // Debugging line
                        break;
                      case 'Food':
                        notes = selectedDetails!.food.isNotEmpty
                            ? 'Food: ${selectedDetails!.food}\nCaretaker: ${selectedDetails!.foodCaretaker}'
                            : 'No food details';
                        print('Food notes: $notes'); // Debugging line
                        break;
                      case 'Snack':
                        notes = selectedDetails!.snack.isNotEmpty
                            ? 'Snack: ${selectedDetails!.snack}'
                            : 'No snack details';
                        print('Snack notes: $notes'); // Debugging line
                        break;
                      case 'Sleep':
                        notes = selectedDetails!.sleep.isNotEmpty
                            ? 'Sleep: ${selectedDetails!.sleep}'
                            : 'No sleep details';
                        print('Sleep notes: $notes'); // Debugging line
                        break;
                      case 'Medicine':
                        notes = selectedDetails!.medicine.isNotEmpty
                            ? 'Medicine: ${selectedDetails!.medicine}\nCaretaker: ${selectedDetails!.medicineCaretaker}'
                            : 'No medicine details';
                        print('Medicine notes: $notes'); // Debugging line
                        break;
                      case 'Assignment':
                        notes = selectedDetails!.assignment.isNotEmpty
                            ? 'Assignment: ${selectedDetails!.assignment}\nCaretaker: ${selectedDetails!.assignmentCaretaker}'
                            : 'No assignment details';
                        print('Assignment notes: $notes'); // Debugging line
                        break;
                      case 'Checkout':
                        notes = selectedDetails!.checkoutTime.isNotEmpty
                            ? 'Checkout Time: ${selectedDetails!.checkoutTime}\nCaretaker: ${selectedDetails!.checkoutCaretaker}'
                            : 'No checkout details';
                        print('Checkout notes: $notes'); // Debugging line
                        break;
                      case 'Notes':
                        notes = selectedDetails!.enrollNote.isNotEmpty
                            ? 'Additional Notes: ${selectedDetails!.enrollNote}'
                            : 'No additional notes';
                        print('Notes: $notes'); // Debugging line
                        break;
                      default:
                        notes = 'No details available';
                        break;
                    }
                  }

                  return Container(
                    color: pastelColors[index % pastelColors.length],
                    child: ListTile(
                      leading: Icon(icon, color: Colors.blue),
                      title: Text(
                        title,
                        style: const TextStyle(color: Color(0xFF231123)),
                      ),
                      subtitle: Text(
                        notes,
                        style: const TextStyle(color: Color(0xFF231123)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Menampilkan catatan hari ini di bawah daftar detail
            if (notesToday.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...notesToday.map((note) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          note['notes'] ?? 'No notes available',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
