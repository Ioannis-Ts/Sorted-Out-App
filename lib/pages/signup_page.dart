import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers για να παίρνουμε τα δεδομένα
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Μεταβλητές για την ορατότητα των κωδικών
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6), // Κρεμ φόντο
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            height: 180, // Λίγο πιο κοντό από το login για να χωρέσουν τα πεδία
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF95A0FF), // Μωβ header
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sign up now!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black12,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Fill your information to sign up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                // Κουμπί επιστροφής (Βελάκι δεξιά όπως στο Figma)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Επιστροφή στο Login
                    },
                  ),
                )
              ],
            ),
          ),

          // --- ΦΟΡΜΑ ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // 1. Username Field
                  _buildTextField(
                    controller: _usernameController,
                    label: "Username",
                    icon: Icons.person_outline,
                  ),
                  
                  const SizedBox(height: 20),

                  // 2. Email Field
                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 20),

                  // 3. Password Field
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
                  
                  // Μικρό κειμενάκι οδηγιών (από το Figma)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 5),
                      child: Text(
                        "Password must contain one uppercase and one lowercase character",
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Confirm Password Field
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

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                      // 1. Ελέγχουμε αν οι κωδικοί ταιριάζουν
                        if (_passwordController.text != _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Passwords do not match!")),
                           );
                         return;
                        }

                      // 2. Προσπάθεια εγγραφής
                      try {
                      // Δημιουργία χρήστη στο Authentication
                          UserCredential userCredential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              );

                      // 3. Αποθήκευση του Username στο Firestore (Βάση Δεδομένων)
                      // Φτιάχνουμε έναν φάκελο 'users' και βάζουμε μέσα τα στοιχεία
                           await FirebaseFirestore.instance
                               .collection('users')
                               .doc(userCredential.user!.uid)
                              .set({
                            'username': _usernameController.text.trim(),
                            'email': _emailController.text.trim(),
                            'uid': userCredential.user!.uid,
                            });

    // Αν όλα πάνε καλά, μήνυμα επιτυχίας και επιστροφή
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );
      Navigator.pop(context); // Γυρνάμε στο Login για να συνδεθεί
    }
  } on FirebaseAuthException catch (e) {
    // Διαχείριση λαθών (π.χ. το email υπάρχει ήδη)
    String message = "Something went wrong";
    if (e.code == 'weak-password') {
      message = 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      message = 'The account already exists for that email.';
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF95A0FF),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
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

  // --- ΒΟΗΘΗΤΙΚΕΣ ΣΥΝΑΡΤΗΣΕΙΣ (ΓΙΑ ΝΑ ΜΗ ΓΡΑΦΟΥΜΕ ΤΟΝ ΙΔΙΟ ΚΩΔΙΚΑ ΠΟΛΛΕΣ ΦΟΡΕΣ) ---

  // Για απλά πεδία (Username, Email)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF5E35B1)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7E57C2), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5E35B1), width: 2),
        ),
        suffixIcon: const Icon(Icons.cancel_outlined, color: Colors.grey),
      ),
    );
  }

  // Για πεδία κωδικών
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF5E35B1)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7E57C2), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5E35B1), width: 2),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[700],
              ),
              onPressed: onVisibilityChanged,
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.cancel_outlined, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}