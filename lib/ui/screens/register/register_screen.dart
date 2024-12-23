import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _registerUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('All fields are required');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );// Navigate to home screen
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                ),
              TextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                    color: Colors.amberAccent,
                  ),
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email, color: Colors.amberAccent,),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, // Color for the border when not focused
                      width: 1.5, // Optional: Border width
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.amberAccent, // Color for the border when focused
                      width: 2.0, // Optional: Border width
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                    color: Colors.amberAccent,
                  ),
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.amberAccent,),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, // Color for the border when not focused
                      width: 1.5, // Optional: Border width
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.amberAccent, // Color for the border when focused
                      width: 2.0, // Optional: Border width
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                    color: Colors.amberAccent,
                  ),
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.amberAccent,),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, // Color for the border when not focused
                      width: 1.5, // Optional: Border width
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.amberAccent, // Color for the border when focused
                      width: 2.0, // Optional: Border width
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_isLoading) const CircularProgressIndicator() else ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Theme.of(context).colorScheme.inversePrimary,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Register'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
