import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/user.dart';
import 'package:myapp/tab/enroll_kids.dart';
import 'package:myapp/tab/cctv.dart';

class Child {
  final String id;
  final String name;

  Child({required this.id, required this.name});
}

class EnrollmentDetails {
  final String idKids;
  final String idDaycare;
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
    required this.idDaycare,
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
      idDaycare: json['id_daycare'] ?? '',
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
  List<dynamic> notesToday = [];

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
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          children = jsonResponse
              .map((child) =>
                  Child(id: child['id_kids'], name: child['name_kids']))
              .toList();
        });
      }
    }
  }

  Future<void> fetchEnrollmentDetails(String childId) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:3000/enroll_history_today/$childId'));

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body == 'null') {
          setState(() {
            selectedDetails = null;
          });
          return;
        }

        List jsonResponse = json.decode(response.body);

        if (jsonResponse.isNotEmpty) {
          var todayEnrollments = jsonResponse.where((data) {
            return data['enroll_date'] != null &&
                data['enroll_date'].startsWith(today);
          }).toList();

          if (todayEnrollments.isNotEmpty) {
            var data = todayEnrollments[0];
            setState(() {
              selectedDetails = EnrollmentDetails.fromJson(data);
              fetchNotesToday(childId);
            });
          } else {
            setState(() {
              selectedDetails = null;
            });
          }
        } else {
          setState(() {
            selectedDetails = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        selectedDetails = null;
      });
    }
  }

  Future<void> fetchNotesToday(String childId) async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/notes_today/$childId'));

    if (response.statusCode == 200) {
      if (response.body != 'null') {
        try {
          List<dynamic> notes = json.decode(response.body) as List<dynamic>;
          setState(() {
            notesToday = notes;
          });
        } catch (e) {
          setState(() {
            notesToday = [];
          });
        }
      } else {
        setState(() {
          notesToday = [];
        });
      }
    }
  }

  void _showAccessCodeDialog(BuildContext context, String userId) {
    final TextEditingController accessCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Access Code'),
          content: TextField(
            controller: accessCodeController,
            decoration: const InputDecoration(hintText: "Access Code"),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final accessCode = accessCodeController.text;

                // Validasi input
                if (accessCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Access Code cannot be empty')),
                  );
                  return;
                }

                String? idDaycare = selectedDetails?.idDaycare;
                if (idDaycare == null || idDaycare.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('ID Daycare is not available')),
                  );
                  Navigator.of(context).pop();
                  return;
                }

                final cctvUrl =
                    await fetchCCTVUrl(idDaycare, accessCode, userId);
                print('CCTV URL: $cctvUrl'); // Tambahkan ini untuk debugging
                if (cctvUrl != null && cctvUrl.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CCTVPage(videoUrl: cctvUrl),
                    ),
                  ).then((_) {
                    // Pastikan untuk memeriksa jika navigasi berhasil
                    print('Navigated to CCTVPage with URL: $cctvUrl');
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CCTV link not available')),
                  );
                }

                // Pindahkan pop ke sini jika tidak ada masalah
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> fetchCCTVUrl(
      String idDaycare, String accessCode, String userId) async {
    if (idDaycare.isEmpty || accessCode.isEmpty || userId.isEmpty) {
      print('Invalid parameters for fetching CCTV URL');
      return null;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/cctv'),
      body: jsonEncode({
        "ID_Daycare": idDaycare,
        "Access_Code": accessCode,
        "ID_User": userId,
      }),
      headers: {"Content-Type": "application/json"},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('CCTV Response: $responseData');
      return responseData['link_cctv'] ?? ''; // Pastikan key ini sesuai
    } else {
      print('Failed to fetch CCTV link: ${response.statusCode}');
      return null;
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
                      setState(() {
                        selectedKid = value;
                        if (value != null) {
                          fetchEnrollmentDetails(value);
                        } else {
                          selectedDetails = null;
                          notesToday = [];
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
                  String notes = 'No details available.';

                  if (selectedDetails != null) {
                    switch (title) {
                      case 'Check-In':
                        notes = selectedDetails!.enrollDate.isNotEmpty
                            ? 'Check-In Time: ${selectedDetails!.enrollDate}\nCaretaker: ${selectedDetails!.enrollCaretaker}'
                            : 'No check-in details';
                        break;
                      case 'Mood':
                        notes = selectedDetails!.mood.isNotEmpty
                            ? 'Mood: ${selectedDetails!.mood}'
                            : 'No mood details';
                        break;
                      case 'Food':
                        notes = selectedDetails!.food.isNotEmpty
                            ? 'Food: ${selectedDetails!.food}\nCaretaker: ${selectedDetails!.foodCaretaker}'
                            : 'No food details';
                        break;
                      case 'Snack':
                        notes = selectedDetails!.snack.isNotEmpty
                            ? 'Snack: ${selectedDetails!.snack}'
                            : 'No snack details';
                        break;
                      case 'Sleep':
                        notes = selectedDetails!.sleep.isNotEmpty
                            ? 'Sleep: ${selectedDetails!.sleep}'
                            : 'No sleep details';
                        break;
                      case 'Medicine':
                        notes = selectedDetails!.medicine.isNotEmpty
                            ? 'Medicine: ${selectedDetails!.medicine}\nCaretaker: ${selectedDetails!.medicineCaretaker}'
                            : 'No medicine details';
                        break;
                      case 'Assignment':
                        notes = selectedDetails!.assignment.isNotEmpty
                            ? 'Assignment: ${selectedDetails!.assignment}\nCaretaker: ${selectedDetails!.assignmentCaretaker}'
                            : 'No assignment details';
                        break;
                      case 'Checkout':
                        notes = selectedDetails!.checkoutTime.isNotEmpty
                            ? 'Checkout Time: ${selectedDetails!.checkoutTime}\nCaretaker: ${selectedDetails!.checkoutCaretaker}'
                            : 'No checkout details';
                        break;
                      case 'Notes':
                        notes = selectedDetails!.enrollNote.isNotEmpty
                            ? 'Additional Notes: ${selectedDetails!.enrollNote}'
                            : 'No additional notes';
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
                      offset: const Offset(0, 3),
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
      floatingActionButton: selectedDetails != null
          ? FloatingActionButton(
              onPressed: () {
                String userId = UserSingleton().user?.id ?? '';
                _showAccessCodeDialog(context, userId);
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.videocam),
            )
          : null,
    );
  }
}
