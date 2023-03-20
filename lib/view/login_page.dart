import 'package:evacuation_project/services/firebase_service.dart';
import 'package:evacuation_project/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late FlutterSecureStorage storage;

  @override
  void initState() {
    super.initState();
    storage = const FlutterSecureStorage();
    _getCredentials();
  }

  Future<void> _getCredentials() async {
    final userID = await storage.read(key: 'userID');
    final userPIN = await storage.read(key: 'userPIN');
    setState(() {
      _emailController.text = userID ?? '';
      _passwordController.text = userPIN ?? '';
    });
    if (userID != null && userPIN != null) {
      await _login();
    }
  }

  Future<void> _login() async {
    final message = await getIt.get<FirebaseService>().login(
          userId: _emailController.text,
          userPIN: _passwordController.text,
        );
    if (message!.contains('Zalogowano')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'User ID'),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'PIN',
                ),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            ElevatedButton(
              onPressed: () async {
                await _login();
              },
              child: const Text('Login'),
            ),
            const SizedBox(
              height: 30.0,
            ),
          ],
        ),
      ),
    );
  }
}
