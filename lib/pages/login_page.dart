import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

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
      // Το βασικό background πίσω από όλα (αν φαίνεται κάπου κενό)
      backgroundColor: const Color(0xFFFFF9E6), 
      body: Column(
        children: [
          // --- ΤΜΗΜΑ 1: Header (Μωβ) ---
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 25, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF95A0FF), // Το χαρακτηριστικό μωβ/λουλακί
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Welcome back 👋",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Λευκό κείμενο για αντίθεση
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Login or create an account.",
                  style: TextStyle(
                    color: Colors.white, // Καθαρό λευκό
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // --- ΤΜΗΜΑ 2: Η φόρμα (Κρεμ φόντο) ---
          Expanded(
            child: Container(
              color: const Color(0xFFFFF9E6), // Το κρεμ χρώμα της εικόνας σου
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Email Field
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: "Email",
                        // Μωβ χρώμα στο label όταν είναι ενεργό
                        labelStyle: const TextStyle(color: Color(0xFF5E35B1)), 
                        filled: true,
                        fillColor: Colors.white, // Λευκό μέσα στο κουτάκι
                        // Το μωβ περίγραμμα
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
                    ),

                    const SizedBox(height: 25),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: "Password",
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
                          mainAxisSize: MainAxisSize.min, // Σημαντικό για να μην πιάνει όλο το χώρο
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[700],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                             const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.cancel_outlined, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Forgot password
// Forgot password button logic
Align(
  alignment: Alignment.centerLeft,
  child: TextButton(
    onPressed: () async {
      // 1. Παίρνουμε το email από το πεδίο που γράφει ο χρήστης
      final email = _emailController.text.trim();

      // 2. Αν είναι κενό, του φωνάζουμε λίγο!
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter your email first!"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 3. Στέλνουμε το email επαναφοράς
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password reset link sent! Check your email."),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Αν κάτι πάει στραβά (π.χ. δεν υπάρχει το email)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? "Error sending reset email"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    },
    child: Text(
      "Forgot your password?",
      style: TextStyle(color: Colors.grey[700]),
    ),
  ),
),

                    const SizedBox(height: 20),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
  try {
      // ... κώδικας login ...
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (context.mounted) {
        // ΑΝΤΙΚΑΤΑΣΤΑΣΗ ΤΗΣ ΠΛΟΗΓΗΣΗΣ ΕΔΩ:
        // Αντί για το γενικό '/home', φτιάχνουμε τη διαδρομή δυναμικά με το σωστό ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userId: userCredential.user!.uid, // <--- ΕΔΩ ΕΙΝΑΙ ΤΟ ΚΛΕΙΔΙ!
            ),
          ),
        );
      }

  } on FirebaseAuthException catch (e) {
    // Αν γίνει λάθος (λάθος κωδικός ή email)
    String message = "Login failed";
    if (e.code == 'user-not-found') {
      message = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      message = 'Wrong password provided.';
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red, // Κόκκινο για το λάθος
        ),
      );
    }
  }
},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF95A0FF), // Ίδιο μωβ με το header
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // Πιο στρογγυλεμένες γωνίες όπως στην εικόνα
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white, // Λευκά γράμματα
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Text("or", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 15),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupPage()),
                         );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF95A0FF), // Ίδιο μωβ
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
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