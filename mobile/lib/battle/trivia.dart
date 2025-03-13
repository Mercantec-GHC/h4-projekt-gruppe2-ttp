import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<List<Trivia>> loadTrivia() async {
  return await rootBundle
      .loadString("assets/trivia_questions.json")
      .then((content) => jsonDecode(content) as List<dynamic>)
      .then((questions) =>
          questions.map((trivia) => Trivia.fromJson(trivia)).toList());
}

class Trivia {
  final String category;
  final String question;
  final Answers answers;

  const Trivia(
      {required this.question, required this.category, required this.answers});

  Trivia.fromJson(Map<String, dynamic> obj)
      : category = obj["category"],
        question = obj["question"],
        answers = Answers.fromJson(obj["answers"]);
}

class Answers {
  final Answer topLeft;
  final Answer topRight;
  final Answer bottomLeft;
  final Answer bottomRight;

  const Answers(this.topLeft, this.topRight, this.bottomLeft, this.bottomRight);

  Answers.fromJson(List<dynamic> obj)
      : topLeft = Answer.fromJson(obj[0]),
        topRight = Answer.fromJson(obj[1]),
        bottomLeft = Answer.fromJson(obj[2]),
        bottomRight = Answer.fromJson(obj[3]);
}

class Answer {
  final String text;
  final bool correct;

  const Answer(this.text, {required this.correct});

  Answer.fromJson(Map<String, dynamic> obj)
      : text = obj["text"],
        correct = obj["correct"];
}

sealed class TriviaResult {}

class AnsweredQuestion extends TriviaResult {
  bool correct;

  AnsweredQuestion(this.correct);
}

class TimeoutReached extends TriviaResult {}

Future<TriviaResult> showTriviaDialog(
    {required BuildContext context, required Trivia trivia}) async {
  final value = await Navigator.push<TriviaResult>(
    context,
    MaterialPageRoute(
      builder: (context) => _TriviaDialog(
        question: trivia.question,
        answers: trivia.answers,
      ),
    ),
  );
  if (value is! TriviaResult) {
    return TimeoutReached();
  }
  return value;
}

class _TriviaDialog extends StatefulWidget {
  const _TriviaDialog({required this.question, required this.answers});

  final String question;
  final Answers answers;

  @override
  State<_TriviaDialog> createState() => _TriviaDialogState();
}

class _Pointer extends StatelessWidget {
  final double x;
  final double y;
  const _Pointer({required this.x, required this.y});

  double _size(double value, double max) {
    return clampDouble(value, -0.95, 0.95) * max * 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return LayoutBuilder(
      builder: (_, constraints) => Center(
        child: Container(
          transform: Matrix4.translationValues(
            _size(x, constraints.maxWidth),
            _size(y, constraints.maxHeight),
            0,
          ),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.onPrimary, width: 2.0),
          ),
        ),
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  final String text;
  final bool highlighted;
  const _Answer({required this.text, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: highlighted ? colorScheme.onPrimary : colorScheme.primary,
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: highlighted ? colorScheme.primary : colorScheme.onPrimary,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Vec2d {
  final double x;
  final double y;

  _Vec2d({required this.x, required this.y});
  _Vec2d.zero()
      : x = 0,
        y = 0;
}

typedef WithinBounds = bool Function(double x, double y);

class _TriviaDialogState extends State<_TriviaDialog> {
  _Vec2d ptr = _Vec2d.zero();
  _Vec2d target = _Vec2d.zero();
  int secondsLeftToAnswer = 90;

  late final Timer _answerTimer;
  late final Timer _lerpTimer;
  late final StreamSubscription _gyroscopeSubscription;

  @override
  void initState() {
    _gyroscopeSubscription = gyroscopeEventStream().listen(
      (GyroscopeEvent event) {
        target = _Vec2d(x: target.x + event.y, y: target.y + event.x);
      },
      onError: (error) {},
      cancelOnError: true,
    );
    _lerpTimer = Timer.periodic(Duration(milliseconds: 33), (_) => _lerpPtr());
    _answerTimer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        setState(() {
          secondsLeftToAnswer -= 1;
        });
        if (secondsLeftToAnswer == 0) {
          _timeoutReached();
        }
      },
    );
    super.initState();
  }

  void _pointerMoveFallback(PointerHoverEvent event) {
    target = _Vec2d(x: event.position.dx, y: event.position.dy);
  }

  double _lerpDouble(double pos, double tgt, double alpha) {
    return (tgt - pos) * alpha + pos;
  }

  void _lerpPtr() {
    setState(() {
      ptr = _Vec2d(
        x: _lerpDouble(ptr.x, target.x, 0.1),
        y: _lerpDouble(ptr.y, target.y, 0.1),
      );
    });
  }

  @override
  void dispose() {
    _lerpTimer.cancel();
    _answerTimer.cancel();
    _gyroscopeSubscription.cancel();
    super.dispose();
  }

  bool _isAnswerCorrect() {
    final Answers(
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight
    ) = widget.answers;

    final answers = <({bool correct, WithinBounds withinBounds})>[
      (correct: topLeft.correct, withinBounds: (x, y) => x <= 0 && y <= 0),
      (correct: topRight.correct, withinBounds: (x, y) => x > 0 && y <= 0),
      (correct: bottomLeft.correct, withinBounds: (x, y) => x <= 0 && y > 0),
      (correct: bottomRight.correct, withinBounds: (x, y) => x > 0 && y > 0),
    ];

    final (:correct, withinBounds: _) =
        answers.singleWhere((v) => v.withinBounds(ptr.x, ptr.y));

    return correct;
  }

  void _timeoutReached() {
    final result = TimeoutReached();
    return Navigator.of(context).pop(result);
  }

  void _lockAnswerIn() {
    final result = AnsweredQuestion(_isAnswerCorrect());
    return Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _lockAnswerIn(),
      child: Scaffold(
        body: SafeArea(
          child: Listener(
            onPointerHover: _pointerMoveFallback,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "${widget.question} ($secondsLeftToAnswer)",
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
                _AnswersScreen(answers: widget.answers, ptr: ptr),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Tap to lock answer in",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswersScreen extends StatelessWidget {
  const _AnswersScreen({
    required this.answers,
    required this.ptr,
  });

  final double spacing = 32;
  final Answers answers;
  final _Vec2d ptr;

  Widget _answerColumn({
    required Answer top,
    required Answer bottom,
    required bool highlighted,
  }) {
    return Expanded(
      child: Column(
        spacing: spacing,
        children: [
          Expanded(
            child: _Answer(
              text: top.text,
              highlighted: highlighted && ptr.y <= 0,
            ),
          ),
          Expanded(
            child: _Answer(
              text: bottom.text,
              highlighted: highlighted && ptr.y > 0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                spacing: spacing,
                children: [
                  _answerColumn(
                    top: answers.topLeft,
                    bottom: answers.bottomLeft,
                    highlighted: ptr.x <= 0,
                  ),
                  _answerColumn(
                    top: answers.topRight,
                    bottom: answers.topRight,
                    highlighted: ptr.x > 0,
                  ),
                ],
              ),
            ),
          ),
          _Pointer(x: ptr.x, y: ptr.y)
        ],
      ),
    );
  }
}
