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
    return Flexible(
      fit: FlexFit.loose,
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
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_maxHealth, (idx) => idx < _health)
            .map((filled) => _generateSlot(context, filled))
            .toList());
  }
}

enum UnitType {
  player,
  enemy,
}

class ActiveSoldier extends StatelessWidget {
  const ActiveSoldier({
    super.key,
    required String name,
    required int health,
    required int maxHealth,
    required int damage,
    required UnitType type,
  })  : _maxHealth = maxHealth,
        _health = health,
        _name = name,
        _unitType = type,
        _damage = damage;

  final String _name;
  final int _damage;
  final int _health;
  final int _maxHealth;
  final UnitType _unitType;

  final double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Column(
        verticalDirection: _unitType == UnitType.enemy
            ? VerticalDirection.down
            : VerticalDirection.up,
        children: [
          Row(children: [
            Expanded(child: Text(_name, style: TextStyle(fontSize: _fontSize))),
            Text(" ", style: TextStyle(fontSize: _fontSize)),
            Text("$_damage 🗡️", style: TextStyle(fontSize: _fontSize))
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

  final double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(_name, style: TextStyle(fontSize: _fontSize))),
        Text(" ", style: TextStyle(fontSize: _fontSize)),
        Text("$_damage 🗡️", style: TextStyle(fontSize: _fontSize)),
        Text(" ", style: TextStyle(fontSize: _fontSize)),
        Text("$_maxHealth ❤️", style: TextStyle(fontSize: _fontSize)),
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
    required UnitType type,
  })  : _maxHealth = maxHealth,
        _health = health,
        _unitType = type,
        _name = name;

  final String _name;
  final int _health;
  final int _maxHealth;
  final UnitType _unitType;

  @override
  Widget build(BuildContext context) {
    return Column(
        verticalDirection: _unitType == UnitType.enemy
            ? VerticalDirection.down
            : VerticalDirection.up,
        children: [
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
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...<Widget>[
            Base(
              name: "Jens den mægtige",
              health: 10,
              maxHealth: 10,
              type: UnitType.enemy,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 16.0),
              child: Column(
                children: [
                  Divider(),
                  InactiveSoldier(name: "boring guy", maxHealth: 7, damage: 30),
                  InactiveSoldier(name: "boring guy", maxHealth: 7, damage: 30),
                  InactiveSoldier(name: "boring guy", maxHealth: 7, damage: 30),
                  InactiveSoldier(name: "boring guy", maxHealth: 7, damage: 30),
                  Divider(),
                  ActiveSoldier(
                    name: "cool guy",
                    health: 4,
                    maxHealth: 7,
                    damage: 30,
                    type: UnitType.enemy,
                  ),
                ],
              ),
            ),
          ],
          Text("⚔️", style: TextStyle(fontSize: 32.0)),
          ...<Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 16.0),
              child: Column(
                children: [
                  ActiveSoldier(
                    name: "cool guy",
                    health: 4,
                    maxHealth: 7,
                    damage: 30,
                    type: UnitType.player,
                  ),
                  Divider(),
                  InactiveSoldier(name: "boring guy", maxHealth: 7, damage: 30),
                  InactiveSoldier(name: "boring guy", maxHealth: 7, damage: 30),
                  InactiveSoldier(name: "boring guy", maxHealth: 7, damage: 30),
                  InactiveSoldier(name: "boring guy", maxHealth: 7, damage: 30),
                  Divider(),
                ],
              ),
            ),
            Base(name: "Dig", health: 10, maxHealth: 10, type: UnitType.player),
          ],
        ],
      ),
    );
  }
}
