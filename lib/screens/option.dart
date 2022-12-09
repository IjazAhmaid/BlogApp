import 'package:blogapp/components/round_button.dart';
import 'package:blogapp/screens/login_screen.dart';
import 'package:blogapp/screens/signin.dart';
import 'package:flutter/material.dart';

class OptionScreen extends StatefulWidget {
  const OptionScreen({super.key});

  @override
  State<OptionScreen> createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(image: AssetImage('images/1.png')),
              const SizedBox(
                height: 24,
              ),
              RoundButton(
                  title: 'Login',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  }),
              const SizedBox(
                height: 24,
              ),
              RoundButton(
                  title: 'Register',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignIn()));
                  })
            ],
          ),
        ),
      ),
    );
  }
}
