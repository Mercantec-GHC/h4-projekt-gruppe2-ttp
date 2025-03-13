import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/battle/battle.dart';
import 'package:mobile/battle/trivia.dart';
import 'package:mobile/client.dart' as client;

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  Map<String, dynamic>? _userStats;

  @override
  void initState() {
    super.initState();
    loadUserStats();
  }

  Future<void> loadUserStats() async {
    final res = await client.Client().getUserStats(
        "t"); //remember to replace "t" with username from token (token is not implemented yet)
    if (res is client.SuccessResult<Map<String, dynamic>>) {
      setState(() {
        _userStats = res.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _userStats == null
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Velkommen, ', style: TextStyle(fontSize: 24.0)),
                    TextSpan(
                        text: '${_userStats?["username"]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24.0)),
                  ],
                ),
              ),
              Divider(),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Gange vundet: ',
                        style: TextStyle(fontSize: 20.0)),
                    TextSpan(
                        text: '${_userStats?["wins"]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0)),
                    TextSpan(text: ' 👑', style: TextStyle(fontSize: 20.0)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Gange tabt: ', style: TextStyle(fontSize: 20.0)),
                    TextSpan(
                        text: '${_userStats?["lost"]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0)),
                    TextSpan(text: ' 😞', style: TextStyle(fontSize: 20.0)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Spil i alt: ', style: TextStyle(fontSize: 20.0)),
                    TextSpan(
                        text: '${_userStats?["games_played"]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0)),
                    TextSpan(text: ' ⚔️', style: TextStyle(fontSize: 20.0)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Korrekte svar: ',
                        style: TextStyle(fontSize: 20.0)),
                    TextSpan(
                        text: '${_userStats?["correctness"]}%',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0)),
                    TextSpan(text: ' ✅', style: TextStyle(fontSize: 20.0)),
                  ],
                ),
              ),
            ],
          );
  }
}

class _BattlePage extends StatelessWidget {
  const _BattlePage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Klar til kamp?", style: TextStyle(fontSize: 24.0)),
        SizedBox(height: 16.0),
        FilledButton(
          onPressed: () async {
            final trivia = await loadTrivia();
            if (!context.mounted) return;
            final result = await startBattle(context: context, trivia: trivia);
            await client.Client().saveGame(
              "t",
              won: result.won,
              totalAnswers: result.totalAnswers,
              correctAnswers: result.correctAnswers,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Kom i gang! ⚔️",
              style: TextStyle(fontSize: 24.0),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("%username%", style: TextStyle(fontSize: 24.0)),
        SizedBox(height: 16.0),
        FilledButton(
          onPressed: () {},
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Lock uij",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<StatefulWidget> createState() => _HomeNavigationState();
}

enum _Page {
  homePage,
  battlePage,
  profilePage,
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1000.0),
        child: SizedBox.expand(
          child: Card(
            margin: EdgeInsets.all(20.0),
            elevation: 4.0,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: child,
            ),
          ),
        ),
      );
}

class _HomeNavigationState extends State<HomeNavigation> {
  _HomeNavigationState();

  var _index = _Page.homePage;

  void _setPage(_Page page) => setState(() => _index = page);

  double _fontSize(_Page page) => page == _index ? 32 : 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            switch (index) {
              case 0:
                return _setPage(_Page.homePage);
              case 1:
                return _setPage(_Page.battlePage);
              case 2:
                return _setPage(_Page.profilePage);
              case _:
                throw Exception("unreachable");
            }
          },
          backgroundColor: Theme.of(context).cardColor,
          items: [
            BottomNavigationBarItem(
                label: "Hjem",
                icon: Text("🏠",
                    style: TextStyle(fontSize: _fontSize(_Page.homePage)))),
            BottomNavigationBarItem(
                label: "Start kamp",
                icon: Text("🆚",
                    style: TextStyle(fontSize: _fontSize(_Page.battlePage)))),
            BottomNavigationBarItem(
                label: "Profil",
                icon: Text("👤",
                    style: TextStyle(fontSize: _fontSize(_Page.profilePage))))
          ]),
      body: Center(
        child: switch (_index) {
          _Page.profilePage => _CardContainer(child: _ProfilePage()),
          _Page.homePage => _CardContainer(child: _HomePage()),
          _Page.battlePage => _BattlePage(),
        },
      ),
    );
  }
}
