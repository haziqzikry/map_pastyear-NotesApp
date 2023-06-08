import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:map_exam/home_screen.dart';
import 'package:map_exam/routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final NavigatorState navigator = navigatorKey.currentState!;
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final ScaffoldMessengerState scaffoldMessenger =
    scaffoldMessengerKey.currentState!;

class LoginScreen extends StatefulWidget {
  static WidgetBuilder route() => (_) => const LoginScreen();
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Signed in successfully'),
          backgroundColor: Colors.green,
        ),
      );

      navigator.pushNamed(Routes.home);
    } catch (err) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(err.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) return;

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Already signed in'),
          backgroundColor: Colors.green,
        ),
      );

      navigator.pushNamed(Routes.home);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please sign in', style: TextStyle(fontSize: 35.0)),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration:
                    const InputDecoration(hintText: 'Type your email here'),
                onTap: () {},
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: 'Type your password',
                ),
                onTap: () {},
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(child: const Text('Sign in'), onPressed: signIn),
            ],
          ),
        ),
      ),
    );
  }
}
