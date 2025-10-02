import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'widgets/filter_form.dart';
import 'widgets/heatmap.dart';
import 'widgets/accident_report.dart';

void main() {
  runApp(const ProviderScope(child: AccidentSafetyApp()));
}

class AccidentSafetyApp extends StatelessWidget {
  const AccidentSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Factory Safety Analytics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF030213)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullscreen = ref.watch(uiFullscreenProvider);
    final collapsed = ref.watch(uiSidebarCollapsedProvider);

    return Scaffold(
      body: Row(
        children: [
          if (!fullscreen)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: collapsed ? 56 : 320,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: collapsed
                  ? SafeArea(
                      child: IconButton(
                        tooltip: 'Expand',
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => ref.read(uiSidebarCollapsedProvider.notifier).state = false,
                      ),
                    )
                  : const _SidebarContent(),
            ),
          Expanded(
            child: Column(
              children: [
                const _TopBar(),
                const Expanded(child: _MainContent()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: fullscreen
          ? FloatingActionButton.extended(
              onPressed: () => ref.read(uiFullscreenProvider.notifier).state = false,
              label: const Text('Exit Fullscreen'),
              icon: const Icon(Icons.fullscreen_exit),
            )
          : null,
    );
  }
}

class _SidebarContent extends ConsumerWidget {
  const _SidebarContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Factory Safety Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Analyze accident data and identify dangerous areas',
                style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(height: 16),
            const Expanded(child: FilterForm()),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ref.read(uiSidebarCollapsedProvider.notifier).state = true,
              icon: const Icon(Icons.keyboard_double_arrow_left),
              label: const Text('Collapse Panel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredAccidentsProvider);
    final filters = ref.watch(filterProvider);
    final hasGenerated = items.isNotEmpty || filters.factory.isNotEmpty;

    if (!hasGenerated) return const SizedBox(height: 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          Text('${filters.factory.isEmpty ? "Selected factory" : filters.factory} - Safety Analysis',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => ref.read(uiFullscreenProvider.notifier).state =
                !ref.read(uiFullscreenProvider),
            icon: const Icon(Icons.fullscreen),
            label: const Text('Fullscreen View'),
          ),
        ],
      ),
    );
  }
}

class _MainContent extends ConsumerWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accidents = ref.watch(filteredAccidentsProvider);
    final filters = ref.watch(filterProvider);

    final hasGenerated = accidents.isNotEmpty || filters.factory.isNotEmpty;

    if (!hasGenerated) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No Data to Display', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Select a factory and generate a heatmap to view accident data'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            children: [
              // Heatmap
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FactoryHeatmap(accidents: accidents, factory: filters.factory),
                ),
              ),
              const SizedBox(height: 16),
              // Report
              AccidentReport(accidents: accidents, factory: filters.factory, dateRange: (filters.startDate, filters.endDate)),
            ],
          ),
        ),
      ),
    );
  }
}
