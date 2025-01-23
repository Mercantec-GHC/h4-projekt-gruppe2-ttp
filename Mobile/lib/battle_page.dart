import 'package:flutter/material.dart';
import 'package:mobile/gorbie.dart';

class Healthbar extends StatelessWidget {
  const Healthbar({
    super.key,
    required int health,
    required int maxHealth,
    required double height,
  })  : _maxHealth = maxHealth,
        _health = health,
        _height = height;

  final int _health;
  final int _maxHealth;
  final double _height;

  Widget _generateSlot(BuildContext context, bool filled) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.0),
        child: Container(
          height: _height,
          color: filled ? Theme.of(context).primaryColor : Colors.redAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        children: List.generate(_maxHealth, (idx) => idx < _health)
            .map((filled) => _generateSlot(context, filled))
            .toList());
  }
}

class ActiveSoldier extends StatelessWidget {
  const ActiveSoldier(
      {super.key,
      required String name,
      required int health,
      required int maxHealth,
      required int damage})
      : _maxHealth = maxHealth,
        _health = health,
        _name = name,
        _damage = damage;

  final String _name;
  final int _damage;
  final int _health;
  final int _maxHealth;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: Text(_name, style: TextStyle(fontSize: 20.0))),
        Text("$_damage 🗡️", style: TextStyle(fontSize: 20.0))
      ]),
      SizedBox(height: 8.0),
      Healthbar(health: _health, maxHealth: _maxHealth, height: 24)
    ]);
  }
}

class InactiveSoldier extends StatelessWidget {
  const InactiveSoldier(
      {super.key,
      required String name,
      required int maxHealth,
      required int damage})
      : _maxHealth = maxHealth,
        _name = name,
        _damage = damage;

  final String _name;
  final int _damage;
  final int _maxHealth;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: Text(_name)),
        Text("$_damage 🗡️"),
        Text(" "),
        Text("$_maxHealth ❤️"),
      ]),
    ]);
  }
}

class Base extends StatelessWidget {
  const Base({
    super.key,
    required String name,
    required int health,
    required int maxHealth,
  })  : _maxHealth = maxHealth,
        _health = health,
        _name = name;

  final String _name;
  final int _health;
  final int _maxHealth;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        _name,
        style: TextStyle(fontSize: 24.0),
      ),
      SizedBox(height: 16.0),
      Healthbar(health: _health, maxHealth: _maxHealth, height: 32),
    ]);
  }
}

class BattlePage extends StatelessWidget {
  const BattlePage({super.key, required gorbie}) : _gorbie = gorbie;

  final Gorbie _gorbie;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...<Widget>[
                Base(name: "Jens den mægtige", health: 10, maxHealth: 10),
                Divider(height: 16.0, indent: 50.0, endIndent: 50.0),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 100.0, vertical: 16.0),
                  child: Column(
                    children: [
                      InactiveSoldier(
                          name: "boring guy", maxHealth: 7, damage: 30),
                      InactiveSoldier(
                          name: "boring guy", maxHealth: 7, damage: 30),
                      InactiveSoldier(
                          name: "boring guy", maxHealth: 7, damage: 30),
                      InactiveSoldier(
                          name: "boring guy", maxHealth: 7, damage: 30),
                      Divider(),
                      ActiveSoldier(
                          name: "cool guy",
                          health: 4,
                          maxHealth: 7,
                          damage: 30),
                    ],
                  ),
                ),
              ],
              Text("⚔️", style: TextStyle(fontSize: 32.0)),
              ...<Widget>[
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 100.0, vertical: 16.0),
                  child: Column(
                    children: [
                      ActiveSoldier(
                          name: "cool guy",
                          health: 4,
                          maxHealth: 7,
                          damage: 30),
                      Divider(),
                      InactiveSoldier(
                          name: "boring guy", maxHealth: 7, damage: 30),
                      InactiveSoldier(
                          name: "boring guy", maxHealth: 7, damage: 30),
                      InactiveSoldier(
                          name: "boring guy", maxHealth: 7, damage: 30),
                      InactiveSoldier(
                          name: "boring guy", maxHealth: 7, damage: 30),
                    ],
                  ),
                ),
                Divider(height: 16.0, indent: 50.0, endIndent: 50.0),
                Base(name: "Dig", health: 10, maxHealth: 10),
              ],
            ],
          ),
        )
      ],
    );
  }
}
