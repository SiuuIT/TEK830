import 'package:flutter/material.dart';
import '../models.dart';

class FactoryHeatmap extends StatelessWidget {
  final List<AccidentData> accidents;
  final String factory;
  const FactoryHeatmap({super.key, required this.accidents, required this.factory});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Chip(label: Text('Factory: $factory')),
            Chip(label: Text('Events: ${accidents.length}')),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: AspectRatio(
            aspectRatio: 500/300, // som SVG-ytan i React. 
            child: CustomPaint(
              painter: _HeatmapPainter(accidents),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<AccidentData> accidents;
  _HeatmapPainter(this.accidents);

  // 10x10 grid som i React-koden. 
  static const gridSize = 10;

  Color _severityColor(Severity s) {
    switch (s) {
      case Severity.high: return const Color(0xFFDC2626);
      case Severity.medium: return const Color(0xFFEA580C);
      case Severity.low: return const Color(0xFFCA8A04);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rectPaint = Paint()..style = PaintingStyle.fill;
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF374151)
      ..strokeWidth = 2;

    // Ytterram
    final outer = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    canvas.drawRect(outer, border);

    // Gridpoäng per cell (med vikt per severity)
    final cellW = outer.width / gridSize;
    final cellH = outer.height / gridSize;
    final counts = List.generate(gridSize, (_) => List.filled(gridSize, 0.0));

    double maxCount = 0;
    for (final a in accidents) {
      final gx = (a.x / (100 / gridSize)).floor().clamp(0, gridSize - 1);
      final gy = (a.y / (100 / gridSize)).floor().clamp(0, gridSize - 1);
      final weight = a.severity == Severity.high ? 3 : (a.severity == Severity.medium ? 2 : 1);
      counts[gy][gx] += weight.toDouble();
      if (counts[gy][gx] > maxCount) maxCount = counts[gy][gx];
    }

    Color _heat(double c) {
      if (maxCount <= 0 || c == 0) return const Color(0x1A22C55E); // grön, låg risk
      final intensity = c / maxCount;
      if (intensity < .3) return const Color(0x66FBBF24); // gul
      if (intensity < .6) return const Color(0x99F97316); // orange
      return const Color(0xCCEF4444); // röd
    }

    // Måla heat-celler
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        rectPaint.color = _heat(counts[y][x]);
        final r = Rect.fromLTWH(
          outer.left + x * cellW,
          outer.top + y * cellH,
          cellW,
          cellH,
        );
        canvas.drawRect(r, rectPaint);
      }
    }

    // Rita punkter
    final pointPaint = Paint()..style = PaintingStyle.fill;
    for (final a in accidents) {
      pointPaint.color = _severityColor(a.severity);
      final px = outer.left + (a.x / 100.0) * outer.width;
      final py = outer.top + (a.y / 100.0) * outer.height;
      canvas.drawCircle(Offset(px, py), 4, pointPaint);
      // valfritt: vit kant
      canvas.drawCircle(Offset(px, py), 4, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) =>
      oldDelegate.accidents != accidents;
}
