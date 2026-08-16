// ── Muscle Group ──────────────────────────────────────────
enum MuscleGroup { chest, back, shoulders, biceps, triceps, core, legs, glutes, cardio }

extension MuscleGroupExt on MuscleGroup {
  String get label {
    switch (this) {
      case MuscleGroup.chest:     return 'Chest';
      case MuscleGroup.back:      return 'Back';
      case MuscleGroup.shoulders: return 'Shoulders';
      case MuscleGroup.biceps:    return 'Biceps';
      case MuscleGroup.triceps:   return 'Triceps';
      case MuscleGroup.core:      return 'Core';
      case MuscleGroup.legs:      return 'Legs';
      case MuscleGroup.glutes:    return 'Glutes';
      case MuscleGroup.cardio:    return 'Cardio';
    }
  }

  String get emoji {
    switch (this) {
      case MuscleGroup.chest:     return '🫁';
      case MuscleGroup.back:      return '🔙';
      case MuscleGroup.shoulders: return '💪';
      case MuscleGroup.biceps:    return '💪';
      case MuscleGroup.triceps:   return '🦾';
      case MuscleGroup.core:      return '🎯';
      case MuscleGroup.legs:      return '🦵';
      case MuscleGroup.glutes:    return '🍑';
      case MuscleGroup.cardio:    return '❤️';
    }
  }
}

// ── Exercise slot (Morning / Evening / Custom) ─────────────
enum ExerciseSlot { morning, evening, custom }

extension ExerciseSlotExt on ExerciseSlot {
  String get label {
    switch (this) {
      case ExerciseSlot.morning: return 'Morning';
      case ExerciseSlot.evening: return 'Evening';
      case ExerciseSlot.custom:  return 'Custom';
    }
  }

  String get emoji {
    switch (this) {
      case ExerciseSlot.morning: return '🌅';
      case ExerciseSlot.evening: return '🌙';
      case ExerciseSlot.custom:  return '⚡';
    }
  }
}

// ── Exercise Template (library item) ─────────────────────
class ExerciseTemplate {
  final String id;
  final String name;
  final MuscleGroup muscle;
  final int defaultSets;
  final int defaultReps;
  final String equipment;
  final String tip;
  final bool isTime; // if true, reps = seconds/minutes

  const ExerciseTemplate({
    required this.id,
    required this.name,
    required this.muscle,
    required this.defaultSets,
    required this.defaultReps,
    required this.equipment,
    required this.tip,
    this.isTime = false,
  });
}

// ── Planned Exercise (in a day's plan) ───────────────────
class PlannedExercise {
  final String templateId;
  final String name;
  final MuscleGroup muscle;
  int sets;
  int reps;
  bool done;
  bool isTime;

  PlannedExercise({
    required this.templateId,
    required this.name,
    required this.muscle,
    required this.sets,
    required this.reps,
    this.done = false,
    this.isTime = false,
  });

  Map<String, dynamic> toJson() => {
        'templateId': templateId,
        'name': name,
        'muscle': muscle.name,
        'sets': sets,
        'reps': reps,
        'done': done,
        'isTime': isTime,
      };

  factory PlannedExercise.fromJson(Map<String, dynamic> j) => PlannedExercise(
        templateId: j['templateId'] as String,
        name: j['name'] as String,
        muscle: MuscleGroup.values.firstWhere(
          (m) => m.name == j['muscle'],
          orElse: () => MuscleGroup.core,
        ),
        sets: (j['sets'] as int?) ?? 3,
        reps: (j['reps'] as int?) ?? 10,
        done: (j['done'] as bool?) ?? false,
        isTime: (j['isTime'] as bool?) ?? false,
      );

  factory PlannedExercise.fromTemplate(ExerciseTemplate t) => PlannedExercise(
        templateId: t.id,
        name: t.name,
        muscle: t.muscle,
        sets: t.defaultSets,
        reps: t.defaultReps,
        isTime: t.isTime,
      );
}

// ── Day Plan ─────────────────────────────────────────────
class DayExercisePlan {
  /// key = ExerciseSlot.name
  Map<String, List<PlannedExercise>> slots;
  /// which slots should reflect back into habits
  Set<String> habitLinkedSlots;

  DayExercisePlan({
    Map<String, List<PlannedExercise>>? slots,
    Set<String>? habitLinkedSlots,
  })  : slots = slots ?? {},
        habitLinkedSlots = habitLinkedSlots ?? {};

  List<PlannedExercise> forSlot(ExerciseSlot s) =>
      slots[s.name] ?? [];

  bool get isEmpty => slots.values.every((l) => l.isEmpty);

  Map<String, dynamic> toJson() => {
        'slots': slots.map(
          (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
        ),
        'habitLinkedSlots': habitLinkedSlots.toList(),
      };

  factory DayExercisePlan.fromJson(Map<String, dynamic> j) {
    final rawSlots = j['slots'] as Map<String, dynamic>? ?? {};
    final slots = rawSlots.map(
      (k, v) => MapEntry(
        k,
        (v as List).map((e) => PlannedExercise.fromJson(e as Map<String, dynamic>)).toList(),
      ),
    );
    final linked = ((j['habitLinkedSlots'] as List?) ?? []).cast<String>().toSet();
    return DayExercisePlan(slots: slots, habitLinkedSlots: linked);
  }
}
