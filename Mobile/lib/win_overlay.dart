import 'package:flutter/material.dart';
import 'package:mobile/home_page.dart';

class BattleResultPage extends StatelessWidget {
  const BattleResultPage({
    super.key,
    required this.victory,
  });

  final bool victory;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeNavigation())),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: victory
                      ? ColorScheme.of(context).primary
                      : ColorScheme.of(context).error,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    victory
                        ? "Vinder, vinder, kyllinge aftensmad 😁👍"
                        : "Du tabte, womp womp ☹️👎",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: victory
                            ? ColorScheme.of(context).onPrimary
                            : ColorScheme.of(context).onError),
                  ),
                ),
              ),
              Text("Tryk hvorenten for at komme videre",
                  style: TextStyle(fontSize: 20.0))
            ],
          ),
        ),
      ),
    );
  }
}
