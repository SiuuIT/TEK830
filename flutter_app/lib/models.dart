enum Severity { low, medium, high }
enum Category { accident, incident, nearMiss }

class AccidentData {
  final String id;
  final String factory;
  final String section;
  final DateTime date;
  final double x; // 0..100
  final double y; // 0..100
  final Severity severity;
  final String description;
  final String accidentType;
  final Category category;

  const AccidentData({
    required this.id,
    required this.factory,
    required this.section,
    required this.date,
    required this.x,
    required this.y,
    required this.severity,
    required this.description,
    required this.accidentType,
    required this.category,
  });
}

class FilterData {
  final String factory;
  final String section;
  final DateTime? startDate;
  final DateTime? endDate;
  final String accidentType;
  final Category? category;

  const FilterData({
    this.factory = "",
    this.section = "",
    this.startDate,
    this.endDate,
    this.accidentType = "",
    this.category,
  });

  FilterData copyWith({
    String? factory,
    String? section,
    DateTime? startDate,
    DateTime? endDate,
    String? accidentType,
    Category? category,
  }) => FilterData(
        factory: factory ?? this.factory,
        section: section ?? this.section,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        accidentType: accidentType ?? this.accidentType,
        category: category ?? this.category,
      );
}
