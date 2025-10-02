import 'dart:math';
import 'models.dart';

final factories = [
  'Factory A - North Plant',
  'Factory B - South Plant',
  'Factory C - East Plant',
  'Factory D - West Plant',
];

final sections = [
  'Assembly Line 1',
  'Assembly Line 2',
  'Packaging Department',
  'Quality Control',
  'Warehouse',
  'Machine Shop',
  'Loading Dock',
  'Chemical Processing',
];

final accidentTypes = [
  'Slip and Fall',
  'Machinery Accident',
  'Chemical Exposure',
  'Cut/Laceration',
  'Struck by Object',
  'Back Injury',
  'Burn',
  'Eye Injury',
  'Repetitive Strain',
  'Electrical Shock',
];

final _rng = Random(42);

Severity _sev() {
  final r = _rng.nextDouble();
  if (r < .2) return Severity.high;
  if (r < .6) return Severity.medium;
  return Severity.low;
}

Category _cat() {
  final r = _rng.nextDouble();
  if (r < .5) return Category.accident;
  if (r < .8) return Category.incident;
  return Category.nearMiss;
}

List<AccidentData> generateMockAccidents([int n = 250]) {
  final now = DateTime.now();
  return List.generate(n, (i) {
    final f = factories[_rng.nextInt(factories.length)];
    final s = sections[_rng.nextInt(sections.length)];
    final t = accidentTypes[_rng.nextInt(accidentTypes.length)];
    final date = now.subtract(Duration(days: _rng.nextInt(365)));
    return AccidentData(
      id: 'A$i',
      factory: f,
      section: s,
      date: date,
      x: _rng.nextDouble() * 100,
      y: _rng.nextDouble() * 100,
      severity: _sev(),
      description: '$t at $s',
      accidentType: t,
      category: _cat(),
    );
  });
}
