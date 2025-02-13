import 'package:flutter/material.dart';
import 'package:mobile/battle.dart';
import 'package:mobile/battle_page.dart';
import 'package:provider/provider.dart';

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(text: 'Velkommen, ', style: TextStyle(fontSize: 24.0)),
              TextSpan(
                  text: '%username%',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
            ],
          ),
        ),
        Divider(),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(
                  text: 'Gange vundet: ', style: TextStyle(fontSize: 20.0)),
              TextSpan(
                  text: '42',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              TextSpan(text: ' 👑🤫🧏‍♂️', style: TextStyle(fontSize: 20.0)),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(text: 'Gange tabt: ', style: TextStyle(fontSize: 20.0)),
              TextSpan(
                  text: '99',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              TextSpan(text: ' 💔🥀😞', style: TextStyle(fontSize: 20.0)),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(text: 'Spil i alt: ', style: TextStyle(fontSize: 20.0)),
              TextSpan(
                  text: '141',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              TextSpan(text: ' 🎖️⚔️💥', style: TextStyle(fontSize: 20.0)),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: const <TextSpan>[
              TextSpan(
                  text: 'Korrekte svar: ', style: TextStyle(fontSize: 20.0)),
              TextSpan(
                  text: '77%',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              TextSpan(text: ' 🤓📊✅', style: TextStyle(fontSize: 20.0)),
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
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (builder) => BattlePage(),
            ),
          ),
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
