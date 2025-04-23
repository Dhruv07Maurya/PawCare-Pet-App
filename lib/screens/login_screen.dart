import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paw_care/screens/home_screen.dart';
import 'signup_screen.dart';
import '../services/auth_service.dart';
import '../screens/admin_dashboard_screen.dart'; // Import the admin dashboard

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController captchaController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isAdminLogin = false; // Track if attempting admin login

  String generatedCaptcha = "";

  @override
  void initState() {
    super.initState();
    _generateCaptcha(); // Generate a captcha when the screen loads
  }

  /// Generates a random alphanumeric CAPTCHA (6 characters)
  void _generateCaptcha() {
    const chars = 'AaBbCcDdEeFfGgHh1234567890';
    final random = Random();
    setState(() {
      generatedCaptcha = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    });
  }

  void _login({bool isAdmin = false}) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String enteredCaptcha = captchaController.text.trim();

    if (email.isEmpty || password.isEmpty || enteredCaptcha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    if (enteredCaptcha != generatedCaptcha) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Incorrect CAPTCHA. Try again!")));
      _generateCaptcha();
      captchaController.clear();
      return;
    }

    setState(() {
      _isLoading = true;
      _isAdminLogin = isAdmin;
    });

    try {
      print("Starting login process as ${isAdmin ? 'Admin' : 'User'}");
      String? errorMessage = await _authService.signIn(email, password);
      print("Login process completed, error: $errorMessage");

      // Make sure to check if the widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (errorMessage == null) {
          // Check if admin login credentials are valid
          if (isAdmin) {
            // Check if this user has admin privileges
            bool isAdminUser = await _authService.isAdmin();

            if (isAdminUser) {
              // Navigate to admin dashboard
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDashboardScreen())
              );
            } else {
              // Show error that user is not an admin
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("You don't have admin privileges"))
              );
              // Sign out since non-admin tried to log in as admin
              await _authService.signOut();
            }
          } else {
            // Regular user login - navigate to home screen
            Future.microtask(() {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen())
              );
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    } catch (e) {
      print("Unexpected login error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unexpected error occurred.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60),
                // App Logo or Icon could go here
                Icon(Icons.lock_open, size: 70, color: Colors.orange),
                SizedBox(height: 20),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Sign in to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),

                // Form Fields
                _buildTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                  prefixIcon: Icons.email,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                  prefixIcon: Icons.lock,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Implement forgot password functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Forgot password functionality to be implemented"))
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // CAPTCHA Section
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CAPTCHA Verification",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Text(
                              generatedCaptcha,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh, color: Colors.orange),
                            onPressed: _generateCaptcha,
                            tooltip: "Refresh CAPTCHA",
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _buildTextField(
                        controller: captchaController,
                        hintText: "Enter CAPTCHA",
                        obscureText: false,
                        prefixIcon: Icons.security,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),

                // Login Button
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.orange))
                    : ElevatedButton(
                  onPressed: () => _login(isAdmin: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Admin Login Button (Replaced Guest Login)
                OutlinedButton(
                  onPressed: () => _login(isAdmin: true),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.orange),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "LOGIN AS ADMIN",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange,
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupScreen()),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Enhanced text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required IconData prefixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.orange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
      obscureText: obscureText,
    );
  }
}