import 'dart:collection';
import 'dart:math';

import 'package:mobile/battle/naming.dart';

int _randomInt({required int min, required int max}) {
  final random = Random();
  return random.nextInt(max - min) + min;
}

class Troop {
  final String name;
  final int damage;
  int _health;
  int get health => _health;
  final int maxHealth;

  bool _alive() {
    return _health > 0;
  }

  void _hurt(int damage) {
    _health -= damage;
    if (_health < 0) {
      _health = 0;
    }
  }

  Troop({required this.name, required this.damage, required health})
      : _health = health,
        maxHealth = health;
}

class Base {
  final String name;
  int _health;
  int get health => _health;
  final int maxHealth;

  void _hurt(int damage) {
    _health -= damage;
    if (_health < 0) {
      _health = 0;
    }
  }

  Base({required this.name, required health})
      : _health = health,
        maxHealth = health;
}

Troop _randomTroop() {
  final name = randomTroopName();
  final health = _randomInt(min: 5, max: 10);
  final damage = _randomInt(min: 1, max: 3);
  return Troop(name: name, health: health, damage: damage);
}

class Battle {
  final Base enemy = Base(name: randomEnemyName(), health: 10);
  final Base player = Base(name: "Dig", health: 10);
  final Queue<Troop> _enemyTroops = ListQueue()
    ..add(Troop(name: randomTroopName(), health: 10, damage: 1));
  final Queue<Troop> _playerTroops = ListQueue()
    ..add(Troop(name: randomTroopName(), health: 10, damage: 1));

  List<Troop> get enemyTroops => UnmodifiableListView(_enemyTroops);
  List<Troop> get playerTroops => UnmodifiableListView(_playerTroops);

  void _cullDeadTroops() {
    if (_playerTroops.isNotEmpty) {
      final first = _playerTroops.removeFirst();
      if (first._alive()) {
        _playerTroops.addFirst(first);
      }
    }
    if (_enemyTroops.isNotEmpty) {
      final first = _enemyTroops.removeFirst();
      if (first._alive()) {
        _enemyTroops.addFirst(first);
      }
    }
  }

  bool _shouldAddEnemyTrops() {
    final diceroll = _randomInt(min: 0, max: 100);
    return diceroll < 10;
  }

  void _addEnemyTroop() {
    if (_shouldAddEnemyTrops()) {
      _enemyTroops.addLast(_randomTroop());
    }
  }

  void _applyPlayerAttack() {
    final damage = _playerTroops.isNotEmpty ? _playerTroops.first.damage : 0;

    if (_enemyTroops.isNotEmpty) {
      _enemyTroops.first._hurt(damage);
    } else {
      enemy._hurt(damage);
    }
  }

  void _applyEnemyAttack() {
    final damage = _enemyTroops.isNotEmpty ? _enemyTroops.first.damage : 0;

    if (_playerTroops.isNotEmpty) {
      _playerTroops.first._hurt(damage);
    } else {
      player._hurt(damage);
    }
  }

  void addPlayerTroop() {
    _playerTroops.addLast(_randomTroop());
  }

  void step() {
    _cullDeadTroops();
    _addEnemyTroop();
    _applyPlayerAttack();
    _applyEnemyAttack();
  }
}
