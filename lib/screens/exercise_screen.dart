import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise_models.dart';
import '../providers/app_provider.dart';
import '../data/exercise_library.dart';
import '../widgets/common.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});
  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  MuscleGroup _selectedMuscle = MuscleGroup.chest;
  ExerciseSlot _addToSlot = ExerciseSlot.morning;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF111110) : const Color(0xFFFAFAF9);
    final border  = isDark ? const Color(0x12FFFFFF) : const Color(0x12000000);
    final text3   = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    final surface2 = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);
    final text    = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);

    return TrackerScaffold(
      title: 'daily.track',
      body: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: bg,
              border: Border(bottom: BorderSide(color: border, width: 0.5)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _TabPill(label: '📚 Library',  active: _tab.index == 0, onTap: () => _tab.animateTo(0)),
                const SizedBox(width: 8),
                _TabPill(label: '📋 My Plan',  active: _tab.index == 1, onTap: () => _tab.animateTo(1)),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _LibraryTab(
                  selected: _selectedMuscle,
                  addToSlot: _addToSlot,
                  onMuscleChanged: (m) => setState(() => _selectedMuscle = m),
                  onSlotChanged: (s) => setState(() => _addToSlot = s),
                  isDark: isDark,
                  text: text,
                  text3: text3,
                  surface2: surface2,
                ),
                const _PlanTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Pill ─────────────────────────────────────────────
class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text   = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final text3  = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    final surface2 = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? text : surface2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? (isDark ? const Color(0xFF111110) : Colors.white) : text3,
        )),
      ),
    );
  }
}

// ── Library Tab ──────────────────────────────────────────
class _LibraryTab extends StatelessWidget {
  final MuscleGroup selected;
  final ExerciseSlot addToSlot;
  final ValueChanged<MuscleGroup> onMuscleChanged;
  final ValueChanged<ExerciseSlot> onSlotChanged;
  final bool isDark;
  final Color text, text3, surface2;

  const _LibraryTab({
    required this.selected,
    required this.addToSlot,
    required this.onMuscleChanged,
    required this.onSlotChanged,
    required this.isDark,
    required this.text,
    required this.text3,
    required this.surface2,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = forMuscle(selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Muscle chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: MuscleGroup.values.map((m) {
              final active = m == selected;
              return GestureDetector(
                onTap: () => onMuscleChanged(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: active ? text : surface2,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${m.emoji} ${m.label}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? (isDark ? const Color(0xFF111110) : Colors.white) : text3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // "Add to" slot selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: Row(
            children: [
              Text('Add to:', style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace')),
              const SizedBox(width: 8),
              ...ExerciseSlot.values.map((s) {
                final active = s == addToSlot;
                return GestureDetector(
                  onTap: () => onSlotChanged(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF2563EB) : surface2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${s.emoji} ${s.label}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? Colors.white : text3,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Exercise list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: exercises.length,
            itemBuilder: (ctx, i) => _ExerciseLibraryCard(
              template: exercises[i],
              slot: addToSlot,
              isDark: isDark,
              text: text,
              text3: text3,
              surface2: surface2,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Library Card ─────────────────────────────────────────
class _ExerciseLibraryCard extends StatelessWidget {
  final ExerciseTemplate template;
  final ExerciseSlot slot;
  final bool isDark;
  final Color text, text3, surface2;

  const _ExerciseLibraryCard({
    required this.template,
    required this.slot,
    required this.isDark,
    required this.text,
    required this.text3,
    required this.surface2,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? const Color(0xFF1A1A19) : Colors.white;
    final border  = isDark ? const Color(0x14FFFFFF) : const Color(0x14000000);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Chip('${template.defaultSets}×${template.defaultReps}${template.isTime ? 's' : ''}', text3, surface2),
                    const SizedBox(width: 6),
                    _Chip(template.equipment, text3, surface2),
                  ],
                ),
                const SizedBox(height: 5),
                Text(template.tip, style: TextStyle(fontSize: 11, color: text3, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Consumer<AppProvider>(
            builder: (ctx, p, _) {
              final alreadyAdded = p.todayPlan.forSlot(slot)
                  .any((e) => e.templateId == template.id);
              return GestureDetector(
                onTap: alreadyAdded
                    ? null
                    : () {
                        p.addExerciseToSlot(
                          slot,
                          PlannedExercise.fromTemplate(template),
                        );
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text('Added to ${slot.label}'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: alreadyAdded ? surface2 : const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    alreadyAdded ? '✓' : '+ Add',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: alreadyAdded ? text3 : Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _Chip(String label, Color text3, Color surface2) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
  decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(5)),
  child: Text(label, style: TextStyle(fontSize: 10, color: text3, fontFamily: 'monospace')),
);

// ── Plan Tab ─────────────────────────────────────────────
class _PlanTab extends StatelessWidget {
  const _PlanTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, p, _) {
        final plan = p.todayPlan;
        if (plan.isEmpty) {
          return const EmptyState('No exercises planned today.\nGo to Library and tap + Add.');
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: ExerciseSlot.values.map((slot) {
            final exercises = plan.forSlot(slot);
            if (exercises.isEmpty) return const SizedBox.shrink();
            return _SlotSection(slot: slot, exercises: exercises, plan: plan, provider: p);
          }).toList(),
        );
      },
    );
  }
}

// ── Slot Section ─────────────────────────────────────────
class _SlotSection extends StatelessWidget {
  final ExerciseSlot slot;
  final List<PlannedExercise> exercises;
  final DayExercisePlan plan;
  final AppProvider provider;

  const _SlotSection({
    required this.slot,
    required this.exercises,
    required this.plan,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final text    = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final text3   = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    final surface2 = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);
    final linked  = plan.habitLinkedSlots.contains(slot.name);
    final canLink = slot != ExerciseSlot.custom;
    final complete = provider.isSlotComplete(slot);
    final done    = exercises.where((e) => e.done).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
          child: Row(
            children: [
              Text(
                '${slot.emoji} ${slot.label}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: text,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: complete ? const Color(0xFF16A34A) : surface2,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$done/${exercises.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: complete ? Colors.white : text3,
                  ),
                ),
              ),
              const Spacer(),
              if (canLink)
                GestureDetector(
                  onTap: () => provider.toggleHabitLink(slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: linked ? const Color(0xFF2563EB) : surface2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      linked ? '🔗 In Habits' : '🔗 Link Habit',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: linked ? Colors.white : text3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (canLink && linked)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Text(
              'Completing all exercises will auto-check "${slot.label} Exercise" in Habits.',
              style: TextStyle(fontSize: 10, color: text3, height: 1.4),
            ),
          ),
        ...exercises.asMap().entries.map((e) => _PlannedCard(
              slot: slot,
              index: e.key,
              ex: e.value,
              provider: provider,
              isDark: isDark,
              text: text,
              text3: text3,
              surface2: surface2,
            )),
      ],
    );
  }
}

// ── Planned Exercise Card ─────────────────────────────────
class _PlannedCard extends StatelessWidget {
  final ExerciseSlot slot;
  final int index;
  final PlannedExercise ex;
  final AppProvider provider;
  final bool isDark;
  final Color text, text3, surface2;

  const _PlannedCard({
    required this.slot,
    required this.index,
    required this.ex,
    required this.provider,
    required this.isDark,
    required this.text,
    required this.text3,
    required this.surface2,
  });

  void _editSetsReps(BuildContext context) {
    int sets = ex.sets;
    int reps = ex.reps;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final bg     = isDark ? const Color(0xFF1A1A19) : Colors.white;
          final t      = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
          final t3     = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
          final s2     = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);
          return Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: t)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _StepperField(
                      label: 'Sets',
                      value: sets,
                      min: 1, max: 20,
                      onChanged: (v) => setModal(() => sets = v),
                      isDark: isDark, text: t, text3: t3, surface2: s2,
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _StepperField(
                      label: ex.isTime ? 'Seconds' : 'Reps',
                      value: reps,
                      min: 1, max: 999,
                      onChanged: (v) => setModal(() => reps = v),
                      isDark: isDark, text: t, text3: t3, surface2: s2,
                    )),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    provider.updateExerciseSetsReps(slot, index, sets: sets, reps: reps);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: t,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text('Save', style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF111110) : Colors.white,
                    )),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? const Color(0xFF1A1A19) : Colors.white;
    final border  = isDark ? const Color(0x14FFFFFF) : const Color(0x14000000);

    return Dismissible(
      key: Key('${slot.name}-$index-${ex.templateId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
      ),
      onDismissed: (_) => provider.removeExerciseFromSlot(slot, index),
      child: GestureDetector(
        onTap: () => _editSetsReps(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Row(
            children: [
              // Check button
              GestureDetector(
                onTap: () => provider.toggleExerciseDone(slot, index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ex.done ? const Color(0xFF16A34A) : Colors.transparent,
                    border: Border.all(
                      color: ex.done ? const Color(0xFF16A34A) : (isDark ? const Color(0x33FFFFFF) : const Color(0x33000000)),
                      width: 1.5,
                    ),
                  ),
                  child: ex.done
                      ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ex.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ex.done ? text.withOpacity(0.35) : text,
                        decoration: ex.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${ex.muscle.label}  ·  ${ex.sets} sets × ${ex.reps}${ex.isTime ? 's' : ' reps'}',
                      style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, size: 14, color: text3),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stepper field for the edit modal ──────────────────────
class _StepperField extends StatelessWidget {
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;
  final bool isDark;
  final Color text, text3, surface2;

  const _StepperField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.isDark,
    required this.text,
    required this.text3,
    required this.surface2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: text3)),
        const SizedBox(height: 8),
        Row(
          children: [
            _StepBtn(icon: Icons.remove, onTap: value > min ? () => onChanged(value - 1) : null, isDark: isDark, text: text, surface2: surface2),
            Expanded(
              child: Center(
                child: Text('$value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: text)),
              ),
            ),
            _StepBtn(icon: Icons.add, onTap: value < max ? () => onChanged(value + 1) : null, isDark: isDark, text: text, surface2: surface2),
          ],
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;
  final Color text, surface2;

  const _StepBtn({required this.icon, required this.onTap, required this.isDark, required this.text, required this.surface2});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(7)),
        child: Icon(icon, size: 16, color: onTap != null ? text : text.withOpacity(0.3)),
      ),
    );
  }
}
