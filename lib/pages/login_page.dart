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

  // --- ΒΟΗΘΗΤΙΚΗ ΣΥΝΑΡΤΗΣΗ ΓΙΑ ERROR SNACKBARS ΣΤΟ ΚΑΤΩ ΜΕΡΟΣ ---
  void _showError(String message, {Color color = Colors.redAccent}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent, // Αόρατο background
        elevation: 0,
        duration: const Duration(seconds: 3),
        // ✅ ΑΛΛΑΓΗ: Το margin ορίζει πόσο απέχει από το κάτω μέρος και τα πλάγια
        margin: const EdgeInsets.only(
          bottom: 20, // 20 pixels από το κάτω μέρος της οθόνης
          left: 20,
          right: 20,
        ),
        content: Container(
          decoration: BoxDecoration(
            color: color, // Το χρώμα (κόκκινο/πράσινο/πορτοκαλί)
            borderRadius: BorderRadius.circular(50), // Οβάλ σχήμα
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTexts.generalBody.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Έλεγχος κενών πεδίων
    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in both email and password.", color: Colors.orange);
      return;
    }

    // 2. Προσπάθεια σύνδεσης
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await ProfileSessionService.handleLogin(userCredential.user!.uid);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              userId: userCredential.user!.uid,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 3. Διαχείριση Σφαλμάτων Firebase
      String message = "Login failed. Please try again.";

      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      } else {
        message = e.message ?? "An unknown error occurred.";
      }

      if (mounted) {
        _showError(message);
      }
    } catch (e) {
      if (mounted) {
        _showError("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ourYellow,
      body: Column(
        children: [
          // HEADER
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 25, bottom: 20),
            decoration: const BoxDecoration(
              color: AppColors.main,
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
                      style:
                          AppTexts.generalBody.copyWith(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: AppTexts.generalBody.copyWith(
                            color: AppColors.maindark, fontSize: 16),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.maindark, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.maindark, width: 2),
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
                      style:
                          AppTexts.generalBody.copyWith(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: AppTexts.generalBody.copyWith(
                            color: AppColors.maindark, fontSize: 16),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.maindark, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.maindark, width: 2),
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
                            _showError("Please enter your email first!", color: Colors.orange);
                            return;
                          }

                          try {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email);

                            if (context.mounted) {
                              _showError(
                                  "Password reset link sent! Check your email.",
                                  color: Colors.green);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              _showError("Error: $e");
                            }
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

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
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

                    // Sign up Button
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