import 'dart:async';
import 'package:flutter/material.dart';
import 'package:player_ai/screens/webview.dart';
import 'package:player_ai/widgets/splash_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const WebViewScreen(
          initialUrl: 'https://app.theplayerai.com/',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SplashLogo(),
            SizedBox(height: 10),
            // SplashTitle(),
          ],
        ),
      ),
    );
  }
}
