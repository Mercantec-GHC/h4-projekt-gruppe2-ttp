import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Text("Trivia Crusaders",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Image(
        image: AssetImage('assets/logo.png'),
        width: 200,
      )
    ]);
  }
}
