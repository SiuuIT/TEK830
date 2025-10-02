import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';

class AccidentReport extends StatelessWidget {
  final List<AccidentData> accidents;
  final String factory;
  final (DateTime?, DateTime?) dateRange;

  const AccidentReport({
    super.key,
    required this.accidents,
    required this.factory,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    if (accidents.isEmpty) return const SizedBox.shrink();

    final total = accidents.length;
    final high = accidents.where((a) => a.severity == Severity.high).length;
    final med  = accidents.where((a) => a.severity == Severity.medium).length;
    final low  = accidents.where((a) => a.severity == Severity.low).length;

    int countCat(Category c) => accidents.where((a) => a.category == c).length;
    final acc = countCat(Category.accident);
    final inc = countCat(Category.incident);
    final near = countCat(Category.nearMiss);

    Map<String, int> _countBy<T>(String Function(AccidentData) keyOf) {
      final m = <String, int>{};
      for (final a in accidents) {
        m.update(keyOf(a), (v) => v + 1, ifAbsent: () => 1);
      }
      return Map.fromEntries(m.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    }

    final bySection = _countBy((a) => a.section);
    final byType    = _countBy((a) => a.accidentType);

    String _rangeLabel() {
      final df = DateFormat('MMM dd, yyyy');
      final (start, end) = dateRange;
      if (start == null && end == null) return 'All dates';
      if (start != null && end != null) return '${df.format(start)} - ${df.format(end)}';
      if (start != null) return 'From ${df.format(start)}';
      return 'Until ${df.format(end!)}';
    }

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Safety Incident Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(factory.isEmpty ? 'Selected factory' : factory, style: TextStyle(color: Theme.of(context).hintColor)),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Row(children: [
                    const Icon(Icons.calendar_month, size: 16),
                    const SizedBox(width: 6),
                    Text(_rangeLabel()),
                  ]),
                  Text('Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(
                children: [
                  _StatBox(value: '$total', label: 'Total Events'),
                  _StatBox(value: '$high', label: 'High Severity', color: const Color(0xFFDC2626)),
                  _StatBox(value: '$med',  label: 'Medium Severity', color: const Color(0xFFEA580C)),
                  _StatBox(value: '$low',  label: 'Low Severity', color: const Color(0xFFCA8A04)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatBox(value: '$acc', label: 'Accidents'),
                  _StatBox(value: '$inc', label: 'Incidents'),
                  _StatBox(value: '$near', label: 'Near Misses'),
                ],
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _KeyValueList(title: 'Events by Factory Section', data: bySection),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _KeyValueList(title: 'Events by Accident Type', data: byType),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: FilledButton.icon(
            onPressed: () {
              // Här kan du koppla in PDF-export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF download would be implemented here')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download as PDF'),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  const _StatBox({required this.value, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final bg = switch (color) {
      null => Theme.of(context).colorScheme.surfaceContainerHighest,
      _   => color!.withOpacity(.12),
    };
    final fg = color ?? Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: fg)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }
}

class _KeyValueList extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  const _KeyValueList({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ...data.entries.map((e) => Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
              Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(color: Theme.of(context).dividerColor),
        ],
      )),
    ]);
  }
}
