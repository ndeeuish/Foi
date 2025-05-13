import 'package:flutter/material.dart';
import 'package:foi/auth/services/auth_service.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/pages/home_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isPasswordHidden = true; // Biến trạng thái để ẩn/hiện password
  bool _isConfirmPasswordHidden = true; // Biến trạng thái cho confirm password

  void register() async {
    final _authService = AuthService();

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Please fill in all required fields"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Passwords don't match!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _authService.signUpWithEmailPassword(
        emailController.text,
        passwordController.text,
        nameController.text,
        phoneController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Sign Up Failed"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 80,
                    color: Color.fromARGB(255, 95, 106, 202),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Join us and start your journey",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Full Name Input
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            hintText: "Enter your full name",
                            hintStyle: TextStyle(
                              color: Colors.grey
                                  .withOpacity(0.7), // Làm mờ hint text
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Email Input
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "Enter your email",
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Phone Input
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Phone",
                            hintText: "Enter your phone number",
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Password Input
                        TextField(
                          controller: passwordController,
                          obscureText: _isPasswordHidden,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Enter your password",
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordHidden = !_isPasswordHidden;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Confirm Password Input
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: _isConfirmPasswordHidden,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            hintText: "Confirm your password",
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordHidden =
                                      !_isConfirmPasswordHidden;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sign Up Button
                        MyButton(
                          text: "Sign Up",
                          onTap: register,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login now",
                          style: TextStyle(
                            color: Color.fromARGB(255, 95, 106, 202),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
