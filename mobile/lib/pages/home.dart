import 'package:flutter/material.dart';
import 'package:mobile/battle/battle.dart';
import 'package:mobile/battle/trivia.dart';
import 'package:mobile/client.dart' as client;
import 'package:mobile/controllers/user.dart';
import 'package:provider/provider.dart';

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  client.User? user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return user == null
        ? Center(child: CircularProgressIndicator())
        : Consumer<UserController>(builder: (ctx, controller, _) {
            final user = controller.session!.user;
            final stats = user.stats;
            final wins = stats.wins;
            final gamesPlayed = stats.gamesPlayed;
            final losses = gamesPlayed - wins;
            final correctnessRatio = stats.totalAnswers != 0
                ? stats.correctAnswers / stats.totalAnswers
                : 0;
            return Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Velkommen, ',
                          style: TextStyle(fontSize: 24.0)),
                      TextSpan(
                          text: user.username,
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
                          text: '$wins',
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
                          text: 'Gange tabt: ',
                          style: TextStyle(fontSize: 20.0)),
                      TextSpan(
                          text: '$losses',
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
                          text: 'Spil i alt: ',
                          style: TextStyle(fontSize: 20.0)),
                      TextSpan(
                          text: '$gamesPlayed',
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
                          text: '${correctnessRatio * 100}%',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0)),
                      TextSpan(text: ' ✅', style: TextStyle(fontSize: 20.0)),
                    ],
                  ),
                ),
              ],
            );
          });
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

            if (!context.mounted) return;
            final controller = context.read<UserController>();
            final session = controller.session;
            if (session == null) {
              Navigator.of(context).pop();
              return;
            }

            controller.saveStats(
              session.token,
              client.InputStats(
                correctAnswers: result.correctAnswers,
                totalAnswers: result.totalAnswers,
                won: result.won,
              ),
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
