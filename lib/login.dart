import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'teacher_home_page.dart';
import 'student_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final teachersRef = FirebaseFirestore.instance.collection('teachers');
  final studentsRef = FirebaseFirestore.instance.collection('students');

  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final teacherSnapshot = await teachersRef
          .where('email', isEqualTo: emailController.text)
          .where('password', isEqualTo: passwordController.text)
          .get();

      if (teacherSnapshot.docs.isNotEmpty) {
        final teacherData = teacherSnapshot.docs.first.data();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherHomePage(teacherData: teacherData),
          ),
        );
      } else {
        final studentSnapshot = await studentsRef
            .where('email', isEqualTo: emailController.text)
            .where('password', isEqualTo: passwordController.text)
            .get();

        if (studentSnapshot.docs.isNotEmpty) {
          final studentData = studentSnapshot.docs.first.data();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentHomePage(studentData: studentData),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email or password.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 40),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),
                _buildAnimatedTextField(
                  controller: emailController,
                  labelText: 'Email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildAnimatedTextField(
                  controller: passwordController,
                  labelText: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue.shade800,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Handle forgot password logic here
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
      ),
    );
  }
}
