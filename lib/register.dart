import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _retypePasswordController = TextEditingController();
  final _emailController = TextEditingController();

  bool _passwordsMatch = true;
  bool _isEmailValid = true;
  bool _isFormValid = true;

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _retypePasswordController.text;
    });
  }

  void _checkEmailValidity() {
    setState(() {
      _isEmailValid = EmailValidator.validate(_emailController.text);
    });
  }

  void _checkFormValidity() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _usernameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _retypePasswordController.text.isNotEmpty &&
          _usernameController.text.length >= 8 &&
          _passwordController.text.length >= 8;
    });
  }

  void _submitForm() async {
    _checkFormValidity(); // Ensure all fields are checked

    if (_passwordsMatch && _isEmailValid && _isFormValid) {
      final Map<String, dynamic> userData = {
        'name': _nameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/register'), // or your local IP
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(userData),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration successful")),
          );
          Navigator.pop(context);
        } else {
          final errorResponse = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorResponse['error'] ?? 'Registration failed'),
            ),
          );
        }
      } catch (e) {
        print('Error: $e'); // Log the error for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Please try again.")),
        );
      }
    } else {
      if (!_passwordsMatch) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
      }
      if (!_isEmailValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email format")),
        );
      }
      if (!_isFormValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Please fill all fields and ensure username and password are at least 8 characters long")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1E8FF),
      appBar: AppBar(
        title: const Text(
          'Create Your Account',
          style: TextStyle(color: Color(0xFFA2B6DF)),
        ),
        backgroundColor: const Color(0xFF5C6B9F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color(0xFF414066)),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Color(0xFF414066)),
              ),
              onChanged: (value) => _checkFormValidity(),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF414066)),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                _checkEmailValidity();
                _checkFormValidity();
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Color(0xFF414066)),
              ),
              obscureText: true,
              onChanged: (value) {
                _checkPasswordsMatch();
                _checkFormValidity();
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _retypePasswordController,
              decoration: const InputDecoration(
                labelText: 'Re-type Password',
                labelStyle: TextStyle(color: Color(0xFF414066)),
              ),
              obscureText: true,
              onChanged: (value) {
                _checkPasswordsMatch();
                _checkFormValidity();
              },
            ),
            const SizedBox(height: 20.0),
            if (!_passwordsMatch)
              const Text(
                "Passwords do not match",
                style: TextStyle(color: Colors.red),
              ),
            if (!_isEmailValid)
              const Text(
                "Invalid email format",
                style: TextStyle(color: Colors.red),
              ),
            if (!_isFormValid)
              const Text(
                "Please fill all fields and ensure username and password are at least 8 characters long",
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _passwordsMatch && _isEmailValid && _isFormValid
                  ? _submitForm
                  : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFF414066),
                backgroundColor: const Color.fromARGB(255, 255, 209, 229),
                elevation: 8.0,
                shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
              ),
              child: const Text('REGISTER'),
            ),
          ],
        ),
      ),
    );
  }
}
