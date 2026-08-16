import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/exercise_models.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _ctrl = TextEditingController();
  final _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _add(AppProvider p) {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    p.addHabit(v);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text3 = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    final surface2 = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);

    return TrackerScaffold(
      title: 'daily.track',
      body: Consumer<AppProvider>(
        builder: (ctx, p, _) => Column(
          children: [
            SectionLabel('This week'),
            Expanded(
              child: p.habits.isEmpty
                  ? const EmptyState('No habits yet.\nAdd one below!')
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: p.habits.length,
                      itemBuilder: (_, i) => _HabitCard(habit: p.habits[i], provider: p, days: _days, isDark: isDark, text3: text3, surface2: surface2),
                    ),
            ),
            // Add row
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111110) : const Color(0xFFFAFAF9),
                border: Border(top: BorderSide(color: isDark ? const Color(0x12FFFFFF) : const Color(0x12000000), width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(hintText: 'New habit…', hintStyle: TextStyle(color: Color(0xFFB0AFA8))),
                      onSubmitted: (_) => _add(p),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _AddButton(onTap: () => _add(p)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final AppProvider provider;
  final List<String> days;
  final bool isDark;
  final Color text3;
  final Color surface2;

  const _HabitCard({required this.habit, required this.provider, required this.days, required this.isDark, required this.text3, required this.surface2});

  @override
  Widget build(BuildContext context) {
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final today = provider.todayIdx;

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
      ),
      onDismissed: (_) => provider.deleteHabit(habit.id),
      child: TrackerCard(
        child: Column(
          children: [
            Row(
              children: [
                CheckButton(checked: habit.week[today], onTap: () => provider.toggleHabitToday(habit.id)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(habit.label,
                      style: TextStyle(fontSize: 14, color: habit.week[today] ? text.withOpacity(0.35) : text,
                          decoration: habit.week[today] ? TextDecoration.lineThrough : null)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(99)),
                  child: Text('${habit.streak}d', style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace')),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 32),
                ...List.generate(7, (i) {
                  final done = habit.week[i];
                  final isToday = i == today;
                  return GestureDetector(
                    onTap: () => provider.toggleHabitDay(habit.id, i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 22, height: 22,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: done ? text : surface2,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: done ? text : isToday ? const Color(0xFF78776E) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(days[i], style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: done ? (isDark ? const Color(0xFF111110) : Colors.white) : text3)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final bg = isDark ? const Color(0xFF111110) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: text,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [Icon(Icons.add_rounded, size: 16, color: bg), const SizedBox(width: 4), Text('Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: bg))],
        ),
      ),
    );
  }
}

class _ExercisePlanChip extends StatelessWidget {
  final String habitId;
  final Color text3;
  const _ExercisePlanChip({required this.habitId, required this.text3});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = context.read<AppProvider>();
    final slot = habitId == kMorningExerciseHabitId ? ExerciseSlot.morning : ExerciseSlot.evening;
    final exercises = p.todayPlan.forSlot(slot);
    final done = exercises.where((e) => e.done).length;
    final total = exercises.length;
    if (total == 0) return Text('No exercises planned', style: TextStyle(fontSize: 10, color: text3));
    return Row(
      children: [
        Text('$done/$total exercises', style: TextStyle(fontSize: 10, color: text3, fontFamily: 'monospace')),
        const SizedBox(width: 6),
        Container(
          width: 60, height: 3,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2),
            borderRadius: BorderRadius.circular(99),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: total > 0 ? (done / total).clamp(0.0, 1.0) : 0,
            child: Container(color: const Color(0xFF16A34A)),
          ),
        ),
      ],
    );
  }
}
