import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/components/my_textfiled.dart';
import 'package:foi/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap,});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController password = TextEditingController();

  //login methot
  void login(){
    //authen

    //push
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //logo
          Icon(
            Icons.lock_open_rounded,
            size: 100,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),

          const SizedBox(height: 25),
          //message, slogan
          Text(
            "Food Oi",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          const SizedBox(height: 25),

          // email
          MyTextField(
            controller: emailController,
            hintText: "Email",
            obscureText: false,
          ),

          const SizedBox(height: 10),

          //password
          MyTextField(
            controller: password,
            hintText: "Password",
            obscureText: true,
          ),

          const SizedBox(height: 25),

          //signin button
          MyButton(
            text: "Sign In",
            onTap: login,
          ),

          const SizedBox(height: 25),

          //signup
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Not a member?",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: widget.onTap,
                child: Text(
                  "Register now",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  )
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
