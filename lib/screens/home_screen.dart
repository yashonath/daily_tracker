import 'package:flutter/material.dart';
import 'habits_screen.dart';
import 'todos_screen.dart';
import 'water_screen.dart';
import 'journal_screen.dart';
import 'dashboard_screen.dart';
import 'exercise_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    HabitsScreen(),
    TodosScreen(),
    WaterScreen(),
    JournalScreen(),
    DashboardScreen(),
    ExerciseScreen(),
  ];

  final _labels = ['Habits', 'Tasks', 'Water', 'Journal', 'Overview', 'Exercise'];

  final _icons = [
    Icons.repeat_rounded,
    Icons.checklist_rounded,
    Icons.water_drop_outlined,
    Icons.book_outlined,
    Icons.grid_view_rounded,
    Icons.fitness_center_outlined,
  ];

  final _activeIcons = [
    Icons.repeat_rounded,
    Icons.checklist_rounded,
    Icons.water_drop_rounded,
    Icons.book_rounded,
    Icons.grid_view_rounded,
    Icons.fitness_center_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final navBg   = isDark ? const Color(0xFF1A1A19) : Colors.white;
    final border  = isDark ? const Color(0x18FFFFFF) : const Color(0x14000000);
    final active  = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final inactive = const Color(0xFFB0AFA8);

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: border, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_screens.length, (i) {
                final isActive = _index == i;
                final color    = isActive ? active : inactive;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _index = i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? _activeIcons[i] : _icons[i],
                          color: color,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: isActive
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
