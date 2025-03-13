import 'package:flutter/material.dart';

Future showBattleResult(
    {required BuildContext context, required bool playerWon}) async {
  final value = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _BattleResultPage(
        playerWon: playerWon,
      ),
    ),
  );
  if (value == null) {
    throw Exception("hopefully unreachable?");
  }
  return value;
}

class _BattleResultPage extends StatelessWidget {
  const _BattleResultPage({
    required this.playerWon,
  });

  final bool playerWon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: playerWon
                      ? ColorScheme.of(context).primary
                      : ColorScheme.of(context).error,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    playerWon
                        ? "Vinder, vinder, kyllinge aftensmad 😁👍"
                        : "Du tabte, womp womp ☹️👎",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: playerWon
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
