import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supatha_shuttles/features/auth/presentation/components/google_sign_in_button.dart';
import 'package:supatha_shuttles/features/auth/presentation/components/my_button.dart';
import 'package:supatha_shuttles/features/auth/presentation/components/my_textfield.dart';
import 'package:supatha_shuttles/features/auth/presentation/cubits/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  late final authCubit = context.read<AuthCubit>();

  //login button pressed
  void login() {
    final String email = emailController.text;
    final String pw = pwController.text;

    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email, pw);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill in fields")));
    }
  }

  //forgot password box
  void openForgotPasswordBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot Password?"),
        content: MyTextField(
          controller: emailController,
          hintText: "Enter email..",
          obscureText: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
              onPressed: () async {
                String message =
                    await authCubit.forgotPassword(emailController.text);
                if (message == "Password reset email sent! Check your inbox") {
                  Navigator.pop(context);
                  emailController.clear;
                }

                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(message)));
              },
              child: const Text("Reset"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_open,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    "S U P A T H A   S H U T T L E S",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyTextField(
                    controller: pwController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => openForgotPasswordBox(),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  MyButton(
                    onTap: login,
                    text: "LOGIN",
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text("Or sign in with"),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyGoogleSignInButton(onTap: () async {
                        authCubit.signInWithGoogle();
                      })
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?   ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.togglePages,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            "Register now",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
