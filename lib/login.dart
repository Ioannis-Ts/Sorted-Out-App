import 'package:flutter/material.dart';
import 'theme/app_variables.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController =
      TextEditingController();
  final TextEditingController _signupUsernameController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isSignUp = false; // Toggle between login and sign up

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // To prevent the keyboard from overlapping the UI
      body: Container(
        decoration: BoxDecoration(
          // NEW: background image
          image: const DecorationImage(
            image: AssetImage('assets/images/background.png'), 
            fit: BoxFit.cover, // γεμίζει την οθόνη, κρατά αναλογία
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Change welcome message based on signup state
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children: [
                      Text(
                        isSignUp
                            ? "Sign up now! 🎉" // Updated message
                            : "Welcome back 👋", // Default login message
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C85FF), // Soft blue color
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        isSignUp
                            ? "Fill your information to sign up"
                            : "Login or create an account.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // Toggle between Login and SignUp
                isSignUp ? _buildSignUpForm() : _buildLoginForm(),
                // Toggle button
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSignUp = !isSignUp; // Switch between login and signup
                    });
                  },
                  child: Text(
                    isSignUp
                        ? 'Already have an account? Login'
                        : 'Don’t have an account? Sign Up',
                    style: TextStyle(color: Color(0xFF6C85FF), fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email Text Field
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Color(0xFFB28D6B)), // Beige label
              prefixIcon: Icon(
                Icons.email,
                color: Color(0xFFB28D6B),
              ), // Beige icon
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        // Password Text Field
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Color(0xFFB28D6B)), // Beige label
              prefixIcon: Icon(
                Icons.lock,
                color: Color(0xFFB28D6B),
              ), // Beige icon
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordController.text.isEmpty
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _passwordController.text.isEmpty
                        ? _passwordController.clear()
                        : null;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        // Login Button
        Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Handle login functionality
            },
            child: Text('Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C85FF), // Blue button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        // Sign Up Username Text Field
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _signupUsernameController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: Color(0xFFB28D6B)), // Beige label
              prefixIcon: Icon(
                Icons.account_circle,
                color: Color(0xFFB28D6B),
              ), // Beige icon
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        // Sign Up Email Text Field
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _signupEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Color(0xFFB28D6B)), // Beige label
              prefixIcon: Icon(
                Icons.email,
                color: Color(0xFFB28D6B),
              ), // Beige icon
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        // Sign Up Password Text Field
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _signupPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Color(0xFFB28D6B)), // Beige label
              prefixIcon: Icon(
                Icons.lock,
                color: Color(0xFFB28D6B),
              ), // Beige icon
              suffixIcon: IconButton(
                icon: Icon(
                  _signupPasswordController.text.isEmpty
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _signupPasswordController.text.isEmpty
                        ? _signupPasswordController.clear()
                        : null;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        // Confirm Password Text Field
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: TextStyle(color: Color(0xFFB28D6B)), // Beige label
              prefixIcon: Icon(
                Icons.lock,
                color: Color(0xFFB28D6B),
              ), // Beige icon
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        // Sign Up Button
        Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Handle sign up functionality
            },
            child: Text('Sign Up'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C85FF), // Blue button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
