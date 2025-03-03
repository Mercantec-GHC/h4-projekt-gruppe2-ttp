import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/battle.dart';
import 'package:mobile/win_overlay.dart';

class _Healthbar extends StatelessWidget {
  const _Healthbar({
    required this.health,
    required this.maxHealth,
    required this.height,
  });

  final int health;
  final int maxHealth;
  final double height;

  Widget _generateSlot(BuildContext context, bool filled) {
    return Flexible(
      fit: FlexFit.loose,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.0),
        child: Container(
          height: height,
          color: filled
              ? ColorScheme.of(context).primary
              : ColorScheme.of(context).error,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxHealth, (idx) => idx < health)
            .map((filled) => _generateSlot(context, filled))
            .toList());
  }
}

enum UnitType {
  player,
  enemy,
}

class _ActiveTroop extends StatelessWidget {
  const _ActiveTroop({
    required this.name,
    required this.health,
    required this.maxHealth,
    required this.damage,
    required this.unitType,
  });

  _ActiveTroop.fromTroop(Troop troop, {required this.unitType})
      : name = troop.name,
        health = troop.health,
        maxHealth = troop.maxHealth,
        damage = troop.damage;

  final String name;
  final int damage;
  final int health;
  final int maxHealth;
  final UnitType unitType;

  final double _fontSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Column(
        verticalDirection: unitType == UnitType.enemy
            ? VerticalDirection.down
            : VerticalDirection.up,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(" ", style: TextStyle(fontSize: _fontSize)),
            Text("$damage 🗡️", style: TextStyle(fontSize: _fontSize))
          ]),
          SizedBox(height: 8.0),
          _Healthbar(health: health, maxHealth: maxHealth, height: 24)
        ]);
  }
}

class _InactiveTroop extends StatelessWidget {
  const _InactiveTroop(
      {required this.name, required this.maxHealth, required this.damage});

  _InactiveTroop.fromTroop(
    Troop troop,
  )   : name = troop.name,
        damage = troop.damage,
        maxHealth = troop.maxHealth;

  final String name;
  final int damage;
  final int maxHealth;

  final double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(name, style: TextStyle(fontSize: _fontSize))),
        Text(" ", style: TextStyle(fontSize: _fontSize)),
        Text("$damage 🗡️", style: TextStyle(fontSize: _fontSize)),
        Text(" ", style: TextStyle(fontSize: _fontSize)),
        Text("$maxHealth ❤️", style: TextStyle(fontSize: _fontSize)),
      ]),
    ]);
  }
}

class _Base extends StatelessWidget {
  const _Base({
    required String name,
    required int health,
    required int maxHealth,
    required UnitType type,
  })  : _maxHealth = maxHealth,
        _health = health,
        _unitType = type,
        _name = name;

  _Base.fromBase(Base base, {required UnitType type})
      : _maxHealth = base.maxHealth,
        _health = base.health,
        _unitType = type,
        _name = base.name;

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
          Text(_name, style: TextStyle(fontSize: 24.0)),
          SizedBox(height: 16.0),
          _Healthbar(health: _health, maxHealth: _maxHealth, height: 32),
        ]);
  }
}

class _TroopList extends StatelessWidget {
  final UnitType type;
  final List<Troop> troops;
  const _TroopList({required this.troops, required this.type});

  final _activeTroops = 1;
  final _maxTroops = 3;

  Iterable<_ActiveTroop> _active() => troops
      .take(1)
      .map((troop) => _ActiveTroop.fromTroop(troop, unitType: type));

  Iterable<_InactiveTroop> _inactive() => troops
      .skip(1)
      .take(_maxTroops)
      .map((troop) => _InactiveTroop.fromTroop(troop));

  @override
  Widget build(BuildContext context) {
    return Column(
      verticalDirection: type == UnitType.player
          ? VerticalDirection.down
          : VerticalDirection.up,
      children: [
        ..._active(),
        ...(troops.isNotEmpty ? [Divider()] : []),
        ..._inactive(),
        ...(troops.length > _activeTroops + _maxTroops
            ? [
                Text(
                  "(+${troops.length - _activeTroops - _maxTroops} tropper)",
                  style: TextStyle(fontSize: 18),
                )
              ]
            : []),
        ...(troops.length > _activeTroops ? [Divider()] : []),
      ],
    );
  }
}

class BattlePage extends StatefulWidget {
  const BattlePage({super.key});

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  late final Timer _battleTimer;
  final _battle = Battle();
  final List<OverlayEntry> _overlayEntries = [];

  @override
  void dispose() {
    _battleTimer.cancel();
    _removeAllOverlays();
    super.dispose();
  }

  void _battleTick() {
    final gameOver = _battle.enemy.health <= 0 || _battle.player.health <= 0;
    if (!gameOver) {
      setState(() => _battle.step());
      _removeAllOverlays();
      _dangerIndicator();
      return;
    }
    final playerWon = _battle.enemy.health <= 0;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => BattleResultPage(victory: playerWon)));
  }

  void _addSoldier() {
    setState(() => _battle.addPlayerTroop());
  }

  void dangerOverlay() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => IgnorePointer(
        ignoring: true,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                const Color.fromARGB(80, 255, 82, 82)
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    _overlayEntries.add(overlayEntry);

    if (_battle.playerTroops.isNotEmpty) {
      overlayEntry.remove();
      _overlayEntries.remove(overlayEntry);
    }
  }

  void _dangerIndicator() {
    if (_battle.enemyTroops.isNotEmpty && _battle.playerTroops.isEmpty) {
      dangerOverlay();
    }
  }

  void _removeAllOverlays() {
    for (var overlayEntry in _overlayEntries) {
      overlayEntry.remove();
    }
    _overlayEntries.clear();
  }

  @override
  void initState() {
    _battleTimer = Timer.periodic(Duration(seconds: 1), (_) => _battleTick());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _addSoldier,
              child: Text("Add player soldier"),
            ),
            ...<Widget>[
              _Base.fromBase(_battle.enemy, type: UnitType.enemy),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 16.0),
                child: _TroopList(
                  troops: _battle.enemyTroops,
                  type: UnitType.enemy,
                ),
              ),
            ],
            Text("⚔️", style: TextStyle(fontSize: 32.0)),
            ...<Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 16.0),
                child: _TroopList(
                  troops: _battle.playerTroops,
                  type: UnitType.player,
                ),
              ),
              _Base.fromBase(_battle.player, type: UnitType.player),
            ],
          ],
        ),
      ),
    );
  }
}
