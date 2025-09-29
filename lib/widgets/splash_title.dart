import 'package:flutter/material.dart';

class SplashTitle extends StatelessWidget {
  const SplashTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Player AI",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w500,
        foreground: Paint()
          ..shader = const LinearGradient(
            colors: <Color>[
              Colors.blue,
              Colors.lightBlueAccent,
            ],
          ).createShader(
            Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
          ),
      ),
    );
  }
}
