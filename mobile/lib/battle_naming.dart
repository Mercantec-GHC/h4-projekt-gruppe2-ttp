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
  "Kasper",
  "Chris"
]);
final _titles = List.from([
  "Twitter-problematiske",
  "Mægtige",
  "Forfærdelige",
  "Dårlige",
  "Fromme",
  "2.",
  "3.",
  "7.",
  "10.",

  // AI-Generated :thumbsup: (the Future<T> is now)
  "Håbløse",
  "Mistroiske",
  "Langsomme",
  "Skrøbelige",
  "Kiksede",
  "Ensomme",
  "Generte",
  "Klodsede",
  "Slappe",
  "Modløse",
  "Ængstlige",
  "Tunge",
  "Følsomme",
  "Bange",
  "Cirkulære",
  "Langtrukne",
  "Ansvarsfraskrivende",
  "Larmende",
  "Urolige",
  "Mangelrige",
  "Stille",
  "Sukkende",
  "Jamrende",
  "Irrelevante",
  "Anspændte",
  "Flabede",
  "Mislykkede",
  "Tvivlende",
  "Fattige",
  "Iskolde",
  "Koldhjertede",
  "Pessimistiske",
  "Rystende",
  "Nervøse",
  "Perverse",
  "Tørre",
  "Indelukkede",
  "Lave",
  "Anonyme",
  "Farlige",
  "Værdiløse",
  "Aflukkede",
]);

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
