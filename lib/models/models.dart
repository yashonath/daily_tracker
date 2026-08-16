// ── Habit ──────────────────────────────────────────────
class Habit {
  final String id;
  String label;
  List<bool> week;
  int streak;

  Habit({
    required this.id,
    required this.label,
    List<bool>? week,
    this.streak = 0,
  }) : week = week ?? List.filled(7, false);

  Map<String, dynamic> toJson() => {
        'id'     : id,
        'label'  : label,
        'week'   : week.map((e) => e ? 1 : 0).toList(),
        'streak' : streak,
      };

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
        id     : j['id'] as String,
        label  : j['label'] as String,
        week   : (j['week'] as List).map((e) => e == 1).toList(),
        streak : (j['streak'] as int?) ?? 0,
      );
}

// ── Todo ───────────────────────────────────────────────
enum TaskPriority { high, med, low }

extension TaskPriorityExt on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high: return 'High';
      case TaskPriority.med:  return 'Med';
      case TaskPriority.low:  return 'Low';
    }
  }
}

// Keep 'Priority' as alias so existing screen code still compiles
typedef Priority = TaskPriority;

class Todo {
  final String id;
  String label;
  bool done;
  TaskPriority priority;

  Todo({
    required this.id,
    required this.label,
    this.done = false,
    this.priority = TaskPriority.med,
  });

  Map<String, dynamic> toJson() => {
        'id'      : id,
        'label'   : label,
        'done'    : done,
        'priority': priority.name,
      };

  factory Todo.fromJson(Map<String, dynamic> j) => Todo(
        id      : j['id'] as String,
        label   : j['label'] as String,
        done    : (j['done'] as bool?) ?? false,
        priority: TaskPriority.values.firstWhere(
          (p) => p.name == j['priority'],
          orElse: () => TaskPriority.med,
        ),
      );
}

// ── Water ──────────────────────────────────────────────
class WaterState {
  int glasses;
  int goal;
  double weightKg;
  bool useKg;
  bool alarmEnabled;
  int alarmIntervalMin;

  WaterState({
    this.glasses          = 0,
    this.goal             = 8,
    this.weightKg         = 70,
    this.useKg            = true,
    this.alarmEnabled     = false,
    this.alarmIntervalMin = 60,
  });

  int    get recommendedMl      => (weightKg * 30).round();
  int    get recommendedGlasses => (recommendedMl / 250).round().clamp(1, 20);
  int    get consumedMl         => glasses * 250;
  int    get remainingMl        => ((goal - glasses) * 250).clamp(0, 99999);
  double get pct                => goal > 0 ? (glasses / goal).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() => {
        'glasses'          : glasses,
        'goal'             : goal,
        'weightKg'         : weightKg,
        'useKg'            : useKg,
        'alarmEnabled'     : alarmEnabled,
        'alarmIntervalMin' : alarmIntervalMin,
      };

  factory WaterState.fromJson(Map<String, dynamic> j) => WaterState(
        glasses          : (j['glasses']          as int?)    ?? 0,
        goal             : (j['goal']             as int?)    ?? 8,
        weightKg         : (j['weightKg']         as num?)?.toDouble() ?? 70.0,
        useKg            : (j['useKg']            as bool?)   ?? true,
        alarmEnabled     : (j['alarmEnabled']     as bool?)   ?? false,
        alarmIntervalMin : (j['alarmIntervalMin'] as int?)    ?? 60,
      );
}

// ── Journal ────────────────────────────────────────────
class JournalEntry {
  final String id;
  String title;
  String body;
  String mood;
  DateTime date;

  JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id'   : id,
        'title': title,
        'body' : body,
        'mood' : mood,
        'date' : date.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id   : j['id']    as String,
        title: j['title'] as String,
        body : j['body']  as String,
        mood : j['mood']  as String,
        date : DateTime.parse(j['date'] as String),
      );
}

// ── History (dashboard) ────────────────────────────────
class DayHistory {
  final DateTime date;
  final int habitPct;
  final int tasksDone;
  final int tasksTotal;
  final int waterGlasses;
  final int waterGoal;

  const DayHistory({
    required this.date,
    required this.habitPct,
    required this.tasksDone,
    required this.tasksTotal,
    required this.waterGlasses,
    required this.waterGoal,
  });
}
