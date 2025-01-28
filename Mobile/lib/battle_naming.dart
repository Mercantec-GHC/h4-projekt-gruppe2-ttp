import 'dart:math';

final _random = Random();
final _names = List.from([
  "Mikkel",
  "From",
  "Teis",
  "Theis",
  "Pieter",
  "Phami",
  "Mads",
  "Dooly",
  "Kasper",
  "Chris"
]);
final _titles = List.from(
    ["Mægtige", "Forfærdelige", "Dårlige", "Fromme", "2.", "3.", "7.", "10."]);

String randomTroopName() {
  var index = _random.nextInt(_names.length);
  return _names[index];
}

String randomEnemyName() {
  var nameIndex = _random.nextInt(_names.length);
  var name = _names[nameIndex];
  var titleIndex = _random.nextInt(_titles.length);
  var title = _titles[titleIndex];
  return "$name den $title";
}
