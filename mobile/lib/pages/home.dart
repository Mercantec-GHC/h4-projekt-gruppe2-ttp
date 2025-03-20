import 'package:flutter/material.dart';
import 'package:mobile/battle/battle.dart';
import 'package:mobile/battle/trivia.dart';
import 'package:mobile/client.dart' as client;
import 'package:mobile/controllers/user.dart';
import 'package:provider/provider.dart';

class _StatsPage extends StatelessWidget {
  const _StatsPage();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(builder: (ctx, controller, _) {
      final user = controller.session!.user;
      final stats = user.stats;
      return Column(children: [
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: 'Velkommen, ', style: TextStyle(fontSize: 24.0)),
              TextSpan(
                  text: user.username,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
            ],
          ),
        ),
        Divider(),
        stats != null
            ? Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Gange vundet: ',
                            style: TextStyle(fontSize: 20.0)),
                        TextSpan(
                            text: '${stats.wins}',
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
                            text: '${stats.gamesPlayed - stats.wins}',
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
                            text: '${stats.gamesPlayed}',
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
                            text:
                                '${((stats.totalAnswers != 0 ? stats.correctAnswers / stats.totalAnswers : 0) * 100).round()}%',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20.0)),
                        TextSpan(text: ' ✅', style: TextStyle(fontSize: 20.0)),
                      ],
                    ),
                  ),
                ],
              )
            : Text("Du har ikke spillet nogle spil endnu, se at komme i gang!"),
      ]);
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
    return Consumer<UserController>(
      builder: (context, controller, _) => Column(
        children: [
          Text(controller.session!.user.username,
              style: TextStyle(fontSize: 24.0)),
          SizedBox(height: 16.0),
          FilledButton(
            onPressed: () async {
              await controller.logout();
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Log ud",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

enum _Page {
  stats,
  battle,
  profile,
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

class _HomePageState extends State<HomePage> {
  _HomePageState();

  var _index = _Page.stats;

  void _setPage(_Page page) => setState(() => _index = page);

  double _fontSize(_Page page) => page == _index ? 32 : 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index.index,
          onTap: (index) {
            switch (index) {
              case 0:
                return _setPage(_Page.stats);
              case 1:
                return _setPage(_Page.battle);
              case 2:
                return _setPage(_Page.profile);
              case _:
                throw Exception("unreachable");
            }
          },
          backgroundColor: Theme.of(context).cardColor,
          items: [
            BottomNavigationBarItem(
                label: "Statistik",
                icon: Text("📊",
                    style: TextStyle(fontSize: _fontSize(_Page.stats)))),
            BottomNavigationBarItem(
                label: "Start kamp",
                icon: Text("🆚",
                    style: TextStyle(fontSize: _fontSize(_Page.battle)))),
            BottomNavigationBarItem(
                label: "Profil",
                icon: Text("👤",
                    style: TextStyle(fontSize: _fontSize(_Page.profile))))
          ]),
      body: Center(
        child: switch (_index) {
          _Page.stats => _CardContainer(child: _StatsPage()),
          _Page.battle => _BattlePage(),
          _Page.profile => _CardContainer(child: _ProfilePage()),
        },
      ),
    );
  }
}
