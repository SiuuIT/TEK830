import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import 'mock_data.dart';

final allAccidentsProvider = Provider<List<AccidentData>>((ref) {
  // I din React-app kommer detta från mockAccidents. :contentReference[oaicite:2]{index=2}
  return generateMockAccidents();
});

final filterProvider = StateProvider<FilterData>((ref) => const FilterData());

final filteredAccidentsProvider =
    Provider.autoDispose<List<AccidentData>>((ref) {
  final filters = ref.watch(filterProvider);
  final all = ref.watch(allAccidentsProvider);

  return all.where((a) {
    if (filters.factory.isNotEmpty && a.factory != filters.factory) return false;
    if (filters.section.isNotEmpty && a.section != filters.section) return false;
    if (filters.startDate != null && a.date.isBefore(filters.startDate!)) return false;
    if (filters.endDate != null && a.date.isAfter(filters.endDate!)) return false;
    if (filters.accidentType.isNotEmpty && a.accidentType != filters.accidentType) return false;
    if (filters.category != null && a.category != filters.category) return false;
    return true;
  }).toList();
});

final uiFullscreenProvider = StateProvider<bool>((_) => false);
final uiSidebarCollapsedProvider = StateProvider<bool>((_) => false);
