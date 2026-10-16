import 'package:flutter/material.dart';
import '../../../data/models/taf_test_type.dart';
import '../../core/theme.dart';
import '../catalog/auxiliary_catalog_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_charts_screen.dart';
import '../target_belt/target_belt_screen.dart';
import '../timer/taf_timer_screen.dart';
import '../workout_log/log_workout_dialog.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  TafTestType? _chartInitialTest;
  TafTestType? _catalogInitialCategory;

  void _onNavigateToTab(int index, {TafTestType? initialTestFilter}) {
    setState(() {
      _currentIndex = index;
      if (index == 2 && initialTestFilter != null) {
        _chartInitialTest = initialTestFilter;
      }
    });
  }

  void _onNavigateToCatalog(TafTestType category) {
    setState(() {
      _currentIndex = 3;
      _catalogInitialCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigateToTab: _onNavigateToTab),
      TargetBeltScreen(
        initialTestFilter: _chartInitialTest,
        onNavigateToCatalog: _onNavigateToCatalog,
      ),
      ProgressChartsScreen(initialTestType: _chartInitialTest),
      AuxiliaryCatalogScreen(initialCategory: _catalogInitialCategory),
      const TafTimerScreen(),
      const ProfileScreen(),
    ];

    // Clamped screen index for bottom navigation
    final activeIndex = _currentIndex.clamp(0, 4);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      floatingActionButton:
          _currentIndex !=
              4 // Hide on timer screen
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: () => LogWorkoutDialog.show(context),
              tooltip: 'Registrar Treino',
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.cardBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: activeIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_outlined),
              activeIcon: Icon(Icons.checklist_rounded),
              label: 'Metas TAF',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_rounded),
              activeIcon: Icon(Icons.auto_graph_rounded),
              label: 'Evolução',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Educativos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer_rounded),
              label: 'Cronômetro',
            ),
          ],
        ),
      ),
    );
  }
}
