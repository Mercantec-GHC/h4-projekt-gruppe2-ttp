import 'package:flutter/material.dart';

class Win extends StatelessWidget {
  const Win({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey.withValues(alpha: 600),
          height: MediaQuery.of(context).size.height,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF00FF00),
              borderRadius: BorderRadius.circular(10),
            ),
            width: 400,
            height: 200,
            margin: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                "WIN",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
