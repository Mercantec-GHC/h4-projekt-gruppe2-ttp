import 'package:flutter/material.dart';
import 'package:mobile/battle_page.dart';
import 'package:provider/provider.dart';
import 'package:mobile/battle.dart';
import 'package:mobile/home_page.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "Username",
                          style: TextStyle(fontSize: 36),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          "user_icon.png",
                          scale: 3,
                          alignment: Alignment.topRight,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 3,
                  ),
                  Row(
                    children: [
                      Text(
                        "RECORD: 11-4",
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "ANTAL SPIL I ALT: 15",
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "KORRETHED: 75%",
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
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
