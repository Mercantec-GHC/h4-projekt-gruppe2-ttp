import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/battle/logic.dart';
import 'package:mobile/battle/result_page.dart';
import 'package:mobile/battle/trivia.dart';

class BattleResult {
  final bool won;
  final int correctAnswers;
  final int totalAnswers;

  const BattleResult({
    required this.won,
    required this.correctAnswers,
    required this.totalAnswers,
  });
}

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
  _Base.fromBase(Base base,
      {required UnitType type, required double visualEnemyTimer})
      : _maxHealth = base.maxHealth,
        _health = base.health,
        _unitType = type,
        _name = base.name,
        _visualEnemyTimer = visualEnemyTimer;

  final String _name;
  final int _health;
  final int _maxHealth;
  final UnitType _unitType;
  final double _visualEnemyTimer;

  @override
  Widget build(BuildContext context) {
    return Column(
        verticalDirection: _unitType == UnitType.enemy
            ? VerticalDirection.down
            : VerticalDirection.up,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                  child: Text(_name,
                      style: TextStyle(
                        fontSize: 24.0,
                      ))),
              if (_unitType == UnitType.enemy)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      value: _visualEnemyTimer,
                    ),
                  ),
                ),
            ],
          ),
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

Future<BattleResult> startBattle(
    {required BuildContext context, required List<Trivia> trivia}) async {
  final value = await Navigator.push<BattleResult>(
    context,
    MaterialPageRoute(
      builder: (context) => _BattlePage(trivia: trivia),
    ),
  );
  if (value == null) {
    throw Exception("hopefully unreachable?");
  }
  return value;
}

class _BattlePage extends StatefulWidget {
  final List<Trivia> trivia;

  const _BattlePage({required this.trivia});

  @override
  State<_BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<_BattlePage>
    with TickerProviderStateMixin {
  final battle = Battle();
  late final Timer battleTimer;
  bool battlePaused = false;
  late AnimationController battleTickAnimator;
  bool cooldown = false;
  late AnimationController cooldownAnimator;
  final List<bool> answers = [];
  OverlayEntry? dangerOverlay;
  int countdown = 3;
  late Timer _enemyTimer;
  late AnimationController visualEnemyTimerController;

  void startCountdown() {
    void countdownTick(Timer timer) {
      setState(() => countdown--);
      if (countdown > 0) return;
      final battleTickDuration = Duration(seconds: 1);
      battleTimer = Timer.periodic(battleTickDuration, (_) => battleTick());
      battleTickAnimator
        ..addListener(() => setState(() {}))
        ..repeat(period: battleTickDuration);
      timer.cancel();
      enemyTick();
    }

    Timer.periodic(const Duration(seconds: 1), countdownTick);
  }

  @override
  void initState() {
    super.initState();
    battleTickAnimator = AnimationController(vsync: this);
    visualEnemyTimerController = AnimationController(vsync: this);
    cooldownAnimator =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addListener(() => setState(() {}))
          ..repeat();
    startCountdown();
  }

  @override
  void dispose() {
    battleTimer.cancel();
    battleTickAnimator.dispose();
    cooldownAnimator.dispose();
    _disposeDangerIndicator();
    _enemyTimer.cancel();
    visualEnemyTimerController.dispose();
    super.dispose();
  }

  BattleResult _battleResult() {
    final won = battle.enemy.health <= 0;
    final correctAnswers = answers.where((correct) => correct).length;
    final totalAnswers = answers.length;
    return BattleResult(
      won: won,
      correctAnswers: correctAnswers,
      totalAnswers: totalAnswers,
    );
  }

  void _pauseBattle() {
    battlePaused = true;
    _disposeDangerIndicator();
  }

  void battleTick() async {
    if (battlePaused) {
      _enemyTimer.cancel();
      return;
    }

    final gameOver = battle.enemy.health <= 0 || battle.player.health <= 0;
    if (!gameOver) {
      setState(() => battle.step());
      _showDangerIndicator();
      return;
    }
    _pauseBattle();

    final result = _battleResult();
    await showBattleResult(context: context, won: result.won);
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  void _saveAnswer(AnsweredQuestion result) {
    answers.add(result.correct);
  }

  void _startCooldown() async {
    cooldown = true;
    cooldownAnimator.reset();
    await cooldownAnimator.forward();
    cooldown = false;
  }

  void _addSoldier() async {
    Trivia randomTrivia() {
      return widget.trivia[Random().nextInt(widget.trivia.length)];
    }

    _pauseBattle();
    final result =
        await showTriviaDialog(context: context, trivia: randomTrivia());
    battlePaused = false;
    enemyTick();

    if (result is AnsweredQuestion) {
      _saveAnswer(result);
    }

    _startCooldown();

    switch (result) {
      case AnsweredQuestion(correct: true):
        setState(() => battle.addPlayerTroop());
        break;
      case AnsweredQuestion(correct: false):
      case TimeoutReached():
        break;
    }
  }

  void _disposeDangerIndicator() {
    dangerOverlay?.remove();
    dangerOverlay = null;
  }

  void enemyTick() {
    visualEnemyTimerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _enemyTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      battle.addEnemyTroop();
    });
  }

  void _showDangerIndicator() {
    _disposeDangerIndicator();
    if (battle.playerTroops.isNotEmpty || battle.enemyTroops.isEmpty) {
      return;
    }
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => IgnorePointer(
        ignoring: true,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [
              Colors.transparent,
              const Color.fromARGB(80, 255, 82, 82)
            ]),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    dangerOverlay = entry;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...<Widget>[
                      _Base.fromBase(
                        battle.enemy,
                        type: UnitType.enemy,
                        visualEnemyTimer: visualEnemyTimerController.value,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 16.0),
                        child: _TroopList(
                          troops: battle.enemyTroops,
                          type: UnitType.enemy,
                        ),
                      ),
                    ],
                    Text("⚔️", style: TextStyle(fontSize: 32.0)),
                    ...<Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 16.0),
                        child: _TroopList(
                          troops: battle.playerTroops,
                          type: UnitType.player,
                        ),
                      ),
                      _Base.fromBase(battle.player,
                          type: UnitType.player, visualEnemyTimer: 0),
                    ],
                    SizedBox(height: 16.0),
                    cooldown
                        ? CircularProgressIndicator(
                            value: cooldownAnimator.value)
                        : FilledButton(
                            onPressed: () {
                              if (countdown > 0) return;
                              if (cooldown) return;
                              _addSoldier();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text("[❔] Få soldat!",
                                  style: TextStyle(fontSize: 16.0)),
                            ),
                          ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    value: battleTickAnimator.value,
                  ),
                ),
              ),
              if (countdown > 0)
                Container(
                  color: ColorScheme.of(context).primary,
                  child: Center(
                    child: Text(
                      "Kampen starter om $countdown...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        color: ColorScheme.of(context).onPrimary,
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
