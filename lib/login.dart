import 'package:flutter/material.dart';
import 'package:myapp/main_bar.dart';
import 'package:myapp/register.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      // Pastikan kunci ada sebelum mengakses
      String? idUser = responseBody['id_user'];
      String? nameUser = responseBody['NAME_USER']; // Ganti dengan NAME_USER

      if (idUser != null && nameUser != null) {
        // Simpan ke UserSingleton
        UserSingleton().user = User(
          id: idUser,
          name: nameUser, // Simpan NAME_USER
        );

        print('Login berhasil, menuju halaman utama');

        // Navigasi ke halaman utama
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomTab()),
        );
      } else {
        _showErrorDialog('Login Failed', 'Invalid response from server: $responseBody');
      }
    } else {
      print('Login gagal, status: ${response.statusCode}');
      _showErrorDialog('Login Failed', 'Invalid username or password.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cek jika pengguna sudah login
    if (UserSingleton().user != null) {
      // Jika sudah login, navigasi ke halaman utama
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomTab()),
        );
      });
      return Container(); // Kembali dengan widget kosong
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD1E8FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                SizedBox(
                  width: 250.0,
                  height: 250.0,
                  child: Image.asset('assets/logo.png'),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                  color: Color(0xFF414066),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Color(0xFF414066),
                ),
              ),
              obscureText: true,
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    _usernameController.clear();
                    _passwordController.clear();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5C6B9F),
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                  ),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF414066),
                    backgroundColor: const Color.fromARGB(255, 255, 209, 229),
                    elevation: 8.0,
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                  ),
                  child: const Text('LOGIN'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF5C6B9F),
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                  ),
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                ),
                child: const Text(
                  "Don't have an account? Register",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}