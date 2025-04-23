import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paw_care/screens/home_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController captchaController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  String generatedCaptcha = "";

  @override
  void initState() {
    super.initState();
    _generateCaptcha(); // Generate a new CAPTCHA when the screen loads
  }

  /// Generates a random alphanumeric CAPTCHA (6 characters)
  void _generateCaptcha() {
    const chars = 'AaBbCcDdEeFfGgHh1234567890';
    final random = Random();
    setState(() {
      generatedCaptcha = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    });
  }

  void _signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String enteredCaptcha = captchaController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || enteredCaptcha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    if (enteredCaptcha != generatedCaptcha) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Incorrect CAPTCHA. Try again!")));
      _generateCaptcha();
      captchaController.clear();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? errorMessage = await _authService.signUp(email, password);

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
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
                SizedBox(height: 40),
                // App Logo or Icon could go here
                Icon(Icons.account_circle, size: 70, color: Colors.orange),
                SizedBox(height: 20),
                Text(
                  "Create Account",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Please fill in the details to sign up",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

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
                SizedBox(height: 20),
                _buildTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                ),
                SizedBox(height: 30),

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

                // Sign Up Button
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.orange))
                    : ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "SIGN UP",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        "Login",
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