import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import '../services/profile_session_service.dart';
import '../theme/app_variables.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      body: Column(
        children: [
          // HEADER
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 25, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF95A0FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back 👋",
                  style: AppTexts.generalTitle.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Login or create an account.",
                  style: AppTexts.generalBody.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // FORM
          Expanded(
            child: Container(
              color: AppColors.ourYellow,
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Email
                    TextField(
                      controller: _emailController,
                      style: AppTexts.generalBody.copyWith(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle:
                            AppTexts.generalBody.copyWith(color: AppColors.maindark, fontSize: 16),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.maindark, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.maindark, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.cancel_outlined,
                              color: AppColors.grey),
                          onPressed: () {
                            _emailController.clear();
                            setState(() {});
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: AppTexts.generalBody.copyWith(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle:
                            AppTexts.generalBody.copyWith(color: AppColors.maindark, fontSize: 16),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.maindark, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.maindark, width: 2),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined,
                                  color: AppColors.grey),
                              onPressed: () {
                                _passwordController.clear();
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () async {
                          final email = _emailController.text.trim();
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter your email first!"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Password reset link sent! Check your email."),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: Text(
                          "Forgot your password?",
                          style: AppTexts.generalBody.copyWith(
                            fontSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          UserCredential userCredential =
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );

                          await ProfileSessionService.handleLogin(
                              userCredential.user!.uid);

                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomePage(
                                  userId: userCredential.user!.uid,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.main,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: AppTexts.generalBody.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    Text("or",
                        style: AppTexts.generalBody
                            .copyWith(color: AppColors.grey)),
                    const SizedBox(height: 15),

                    // Sign up
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.main,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          "Sign Up",
                          style: AppTexts.generalBody.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
