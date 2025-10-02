import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../mock_data.dart';
import '../providers.dart';

class FilterForm extends ConsumerStatefulWidget {
  const FilterForm({super.key});

  @override
  ConsumerState<FilterForm> createState() => _FilterFormState();
}

class _FilterFormState extends ConsumerState<FilterForm> {
  late FilterData data;
  bool showAdvanced = false;
  bool generating = false;

  @override
  void initState() {
    super.initState();
    data = ref.read(filterProvider);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? (data.startDate ?? now) : (data.endDate ?? now);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDate: initial,
    );
    if (picked != null) {
      setState(() {
        data = data.copyWith(
          startDate: isStart ? picked : data.startDate,
          endDate: isStart ? data.endDate : picked,
        );
      });
    }
  }

  Future<void> _onGenerate() async {
    setState(() => generating = true);
    // simulera “API delay” (precis som i React-koden) :contentReference[oaicite:5]{index=5}
    await Future<void>.delayed(const Duration(milliseconds: 800));
    ref.read(filterProvider.notifier).state = data;
    setState(() => generating = false);
  }

  @override
  Widget build(BuildContext context) {
    final hint = TextStyle(color: Theme.of(context).hintColor);

    return SingleChildScrollView(
      child: Column(
        children: [
          _Labeled(
            label: 'Factory',
            child: DropdownButtonFormField<String>(
              value: data.factory.isEmpty ? null : data.factory,
              items: factories.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (v) => setState(() => data = data.copyWith(factory: v ?? "")),
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            ),
          ),
          const SizedBox(height: 12),
          _Labeled(
            label: 'Section',
            child: DropdownButtonFormField<String>(
              value: data.section.isEmpty ? null : data.section,
              items: sections.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => data = data.copyWith(section: v ?? "")),
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            ),
          ),
          const SizedBox(height: 12),
          _Labeled(
            label: 'Start Date',
            child: OutlinedButton.icon(
              onPressed: () => _pickDate(isStart: true),
              icon: const Icon(Icons.calendar_month),
              label: Text(data.startDate == null ? 'Select start date' : data.startDate!.toString().split(' ').first),
            ),
          ),
          const SizedBox(height: 12),
          _Labeled(
            label: 'End Date',
            child: OutlinedButton.icon(
              onPressed: () => _pickDate(isStart: false),
              icon: const Icon(Icons.calendar_today),
              label: Text(data.endDate == null ? 'Select end date' : data.endDate!.toString().split(' ').first),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('More Filters', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: Icon(showAdvanced ? Icons.expand_less : Icons.expand_more, color: hint.color),
            onTap: () => setState(() => showAdvanced = !showAdvanced),
          ),
          AnimatedCrossFade(
            crossFadeState: showAdvanced ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            firstChild: Column(
              children: [
                _Labeled(
                  label: 'Accident Type',
                  child: DropdownButtonFormField<String>(
                    value: data.accidentType.isEmpty ? null : data.accidentType,
                    items: accidentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => data = data.copyWith(accidentType: v ?? "")),
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  ),
                ),
                const SizedBox(height: 12),
                _Labeled(
                  label: 'Category',
                  child: DropdownButtonFormField<Category>(
                    value: data.category,
                    items: const [
                      DropdownMenuItem(value: Category.accident, child: Text('Accident')),
                      DropdownMenuItem(value: Category.incident, child: Text('Incident')),
                      DropdownMenuItem(value: Category.nearMiss, child: Text('Near Miss')),
                    ],
                    onChanged: (v) => setState(() => data = data.copyWith(category: v)),
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  ),
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: generating || data.factory.isEmpty ? null : _onGenerate,
              child: Text(generating ? 'Generating...' : 'Generate Heatmap'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  const _Labeled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      child,
    ]);
  }
}
