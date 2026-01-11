import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_variables.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ourYellow,
      body: Column(
        children: [
          // HEADER
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
            decoration: const BoxDecoration(
              color: AppColors.main,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sign up now!",
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
                    const SizedBox(height: 5),
                    Text(
                      "Fill your information to sign up",
                      style: AppTexts.generalBody.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // FORM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  _buildTextField(
                    controller: _usernameController,
                    label: "Username",
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 20),

                  _buildPasswordField(
                    controller: _passwordController,
                    label: "Password",
                    isVisible: _isPasswordVisible,
                    onVisibilityChanged: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 5),
                      child: Text(
                        "Password must contain one uppercase and one lowercase character.",
                        style: AppTexts.generalBody.copyWith(
                          fontSize: 11,
                          color: AppColors.grey2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: "Confirm Password",
                    isVisible: _isConfirmPasswordVisible,
                    onVisibilityChanged: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Passwords do not match!"),
                            ),
                          );
                          return;
                        }

                        try {
                          UserCredential userCredential =
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );

                          await FirebaseFirestore.instance
                              .collection('Profiles')
                              .doc(userCredential.user!.uid)
                              .set({
                            'name': _usernameController.text.trim(),
                            'email': _emailController.text.trim(),
                            'uid': userCredential.user!.uid,
                            'totalpoints': 0,
                            'lastlogin': Timestamp.now(),
                          });

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Account created successfully!"),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } on FirebaseAuthException catch (e) {
                          String message = "Something went wrong";
                          if (e.code == 'weak-password') {
                            message =
                                'The password provided is too weak.';
                          } else if (e.code ==
                              'email-already-in-use') {
                            message =
                                'The account already exists for that email.';
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "Sign up",
                        style: AppTexts.generalBody.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TEXT FIELD
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: AppTexts.generalBody.copyWith(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
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
            controller.clear();
            setState(() {});
          },
        ),
      ),
    );
  }

  // PASSWORD FIELD
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: AppTexts.generalBody.copyWith(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
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
                isVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: AppColors.grey,
              ),
              onPressed: onVisibilityChanged,
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined,
                  color: AppColors.grey),
              onPressed: () {
                controller.clear();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
