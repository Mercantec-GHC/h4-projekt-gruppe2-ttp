import 'package:flutter/material.dart';
import 'package:mobile/battle_page.dart';
import 'package:mobile/user_page.dart';
import 'package:provider/provider.dart';
import 'package:mobile/battle.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xF0D9D9D9),
              ),
              width: 325,
              height: 650,
              margin: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Text(
                    "Hjem",
                    style: TextStyle(fontSize: 48),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: const Color(0xF0D9D9D9),
            height: 80,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Image.asset("house_icon.png"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Image.asset("vs_icon.png"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => Battle(),
                        child: BattlePage(),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Image.asset("user_icon.png"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPage(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
