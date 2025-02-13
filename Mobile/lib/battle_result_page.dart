import 'package:flutter/material.dart';
import 'package:mobile/home_page.dart';

class BattleEndPage extends StatelessWidget {
  const BattleEndPage({
    super.key,
    required this.victory,
  });

  final bool victory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeNavigation())),
        child: Column(
          children: [
            Container(
              color: Colors.grey.withValues(alpha: 600),
              height: MediaQuery.of(context).size.height,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      victory == true ? Color(0xFF00FF00) : Color(0xFFB71C1C),
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 400,
                height: 200,
                margin: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    victory == true ? "YOU WON" : "GOD YOU SUCK",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
