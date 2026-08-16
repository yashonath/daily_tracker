import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/exercise_models.dart';

typedef NotifyCallback = Future<void> Function(String title, String body);

// Habit IDs reserved for exercise habit linking
const String kMorningExerciseHabitId = '__morning_exercise__';
const String kEveningExerciseHabitId = '__evening_exercise__';

class AppProvider extends ChangeNotifier {
  final NotifyCallback? onNotify;

  List<Habit>        habits  = [];
  List<Todo>         todos   = [];
  WaterState         water   = WaterState();
  List<JournalEntry> journal = [];

  // Exercise plans keyed by date "yyyy-MM-dd"
  Map<String, DayExercisePlan> _exercisePlans = {};

  // Daily snapshots keyed "yyyy-MM-dd"
  Map<String, Map<String, int>> _snapshots = {};

  // Alarm
  bool      _alarmEnabled     = false;
  int       _alarmIntervalMin = 60;
  DateTime? _alarmNextFire;
  Timer?    _alarmTimer;
  Timer?    _countdownTimer;
  List<Map<String, String>> alarmLog = [];

  bool      get alarmEnabled     => _alarmEnabled;
  int       get alarmIntervalMin => _alarmIntervalMin;
  DateTime? get alarmNextFire    => _alarmNextFire;

  AppProvider({this.onNotify}) {
    _load();
  }

  // ── Persistence ─────────────────────────────────────────
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final h = prefs.getString('habits');
      if (h != null) {
        habits = (jsonDecode(h) as List)
            .map((e) => Habit.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final t = prefs.getString('todos');
      if (t != null) {
        todos = (jsonDecode(t) as List)
            .map((e) => Todo.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final w = prefs.getString('water');
      if (w != null) water = WaterState.fromJson(jsonDecode(w));
      final j = prefs.getString('journal');
      if (j != null) {
        journal = (jsonDecode(j) as List)
            .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final s = prefs.getString('snapshots');
      if (s != null) {
        final raw = jsonDecode(s) as Map<String, dynamic>;
        _snapshots = raw.map((k, v) =>
            MapEntry(k, Map<String, int>.from(v as Map)));
      }
      final ep = prefs.getString('exercisePlans');
      if (ep != null) {
        final raw = jsonDecode(ep) as Map<String, dynamic>;
        _exercisePlans = raw.map(
          (k, v) => MapEntry(k, DayExercisePlan.fromJson(v as Map<String, dynamic>)),
        );
      }
      _alarmEnabled     = prefs.getBool('alarmEnabled')    ?? false;
      _alarmIntervalMin = prefs.getInt('alarmIntervalMin') ?? 60;
      if (_alarmEnabled) _scheduleAlarm();
    } catch (e) {
      debugPrint('Load error: $e');
    }
    notifyListeners();
  }

  Future<void> _save() async {
    _snapshotToday();
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('habits',    jsonEncode(habits.map((e) => e.toJson()).toList())),
      prefs.setString('todos',     jsonEncode(todos.map((e) => e.toJson()).toList())),
      prefs.setString('water',     jsonEncode(water.toJson())),
      prefs.setString('journal',   jsonEncode(journal.map((e) => e.toJson()).toList())),
      prefs.setString('snapshots', jsonEncode(_snapshots)),
      prefs.setString('exercisePlans', jsonEncode(_exercisePlans.map(
        (k, v) => MapEntry(k, v.toJson()),
      ))),
      prefs.setBool('alarmEnabled',    _alarmEnabled),
      prefs.setInt('alarmIntervalMin', _alarmIntervalMin),
    ]);
  }

  // ── Snapshot ─────────────────────────────────────────────
  String get _todayKey {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}';
  }

  void _snapshotToday() {
    _snapshots[_todayKey] = {
      'habitPct'    : habitCompletionPct,
      'tasksDone'   : todos.where((t) => t.done).length,
      'tasksTotal'  : todos.length,
      'waterGlasses': water.glasses,
      'waterGoal'   : water.goal,
    };
  }

  // ── Dashboard history from real snapshots ────────────────
  List<DayHistory> historyForRange(String range) {
    final now  = DateTime.now();
    final days = range == 'week' ? 7 : range == 'month' ? 30 : 365;
    final list = <DayHistory>[];

    for (int i = days - 1; i >= 0; i--) {
      final d   = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = '${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}';

      if (i == 0) {
        list.add(DayHistory(
          date         : d,
          habitPct     : habitCompletionPct,
          tasksDone    : todos.where((t) => t.done).length,
          tasksTotal   : todos.length,
          waterGlasses : water.glasses,
          waterGoal    : water.goal,
        ));
      } else {
        final snap = _snapshots[key];
        if (snap != null) {
          list.add(DayHistory(
            date         : d,
            habitPct     : snap['habitPct']     ?? 0,
            tasksDone    : snap['tasksDone']    ?? 0,
            tasksTotal   : snap['tasksTotal']   ?? 0,
            waterGlasses : snap['waterGlasses'] ?? 0,
            waterGoal    : snap['waterGoal']    ?? 8,
          ));
        }
      }
    }
    return list;
  }

  // ── Live computed stats ───────────────────────────────────
  int get todayIdx => (DateTime.now().weekday - 1).clamp(0, 6);

  int get habitCompletionPct {
    if (habits.isEmpty) return 0;
    final done = habits.where((h) => h.week[todayIdx]).length;
    return (done / habits.length * 100).round();
  }

  int get tasksDone  => todos.where((t) => t.done).length;
  int get tasksTotal => todos.length;
  int get waterPct   => (water.pct * 100).round();

  // ── Habits ───────────────────────────────────────────────
  void toggleHabitToday(String id) {
    final h = habits.firstWhere((x) => x.id == id);
    h.week[todayIdx] = !h.week[todayIdx];
    h.streak = h.week.where((v) => v).length;
    _save(); notifyListeners();
  }

  void toggleHabitDay(String id, int day) {
    final h = habits.firstWhere((x) => x.id == id);
    h.week[day] = !h.week[day];
    h.streak    = h.week.where((v) => v).length;
    _save(); notifyListeners();
  }

  void addHabit(String label) {
    habits.add(Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
    ));
    _save(); notifyListeners();
  }

  void deleteHabit(String id) {
    habits.removeWhere((h) => h.id == id);
    _save(); notifyListeners();
  }

  // ── Todos ────────────────────────────────────────────────
  void toggleTodo(String id) {
    final t = todos.firstWhere((x) => x.id == id);
    t.done = !t.done;
    _save(); notifyListeners();
  }

  void addTodo(String label, TaskPriority priority) {
    todos.add(Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      priority: priority,
    ));
    _save(); notifyListeners();
  }

  void deleteTodo(String id) {
    todos.removeWhere((t) => t.id == id);
    _save(); notifyListeners();
  }

  // ── Water ─────────────────────────────────────────────────
  void logWater(int delta) {
    final prev    = water.glasses;
    water.glasses = (water.glasses + delta).clamp(0, water.goal);
    if (delta > 0 && water.glasses > prev) _onWaterLogged();
    _save(); notifyListeners();
  }

  void setGlassesTo(int n) {
    final prev    = water.glasses;
    water.glasses = n.clamp(0, water.goal);
    if (water.glasses > prev) _onWaterLogged();
    _save(); notifyListeners();
  }

  void changeWaterGoal(int delta) {
    water.goal    = (water.goal + delta).clamp(1, 20);
    water.glasses = water.glasses.clamp(0, water.goal);
    _save(); notifyListeners();
  }

  void applyWeight(double kg) {
    water.weightKg = kg.clamp(10, 400);
    water.goal     = water.recommendedGlasses;
    water.glasses  = water.glasses.clamp(0, water.goal);
    _save(); notifyListeners();
  }

  void setWeightUnit(bool useKg) {
    water.useKg = useKg;
    _save(); notifyListeners();
  }

  // ── Journal ───────────────────────────────────────────────
  void addJournalEntry(String title, String body, String mood) {
    journal.insert(0, JournalEntry(
      id    : DateTime.now().millisecondsSinceEpoch.toString(),
      title : title,
      body  : body,
      mood  : mood,
      date  : DateTime.now(),
    ));
    _save(); notifyListeners();
  }

  void deleteJournalEntry(String id) {
    journal.removeWhere((e) => e.id == id);
    _save(); notifyListeners();
  }

  // ── Exercise Plans ────────────────────────────────────────
  DayExercisePlan get todayPlan =>
      _exercisePlans[_todayKey] ?? DayExercisePlan();

  void _setTodayPlan(DayExercisePlan plan) {
    _exercisePlans[_todayKey] = plan;
    _syncExerciseHabits(plan);
    _save();
    notifyListeners();
  }

  void addExerciseToSlot(ExerciseSlot slot, PlannedExercise ex) {
    final plan = todayPlan;
    final list = List<PlannedExercise>.from(plan.forSlot(slot))..add(ex);
    plan.slots[slot.name] = list;
    _setTodayPlan(plan);
  }

  void removeExerciseFromSlot(ExerciseSlot slot, int index) {
    final plan = todayPlan;
    final list = List<PlannedExercise>.from(plan.forSlot(slot));
    if (index < list.length) list.removeAt(index);
    plan.slots[slot.name] = list;
    _setTodayPlan(plan);
  }

  void toggleExerciseDone(ExerciseSlot slot, int index) {
    final plan = todayPlan;
    final list = List<PlannedExercise>.from(plan.forSlot(slot));
    if (index < list.length) list[index].done = !list[index].done;
    plan.slots[slot.name] = list;
    _setTodayPlan(plan);
  }

  void updateExerciseSetsReps(ExerciseSlot slot, int index, {int? sets, int? reps}) {
    final plan = todayPlan;
    final list = List<PlannedExercise>.from(plan.forSlot(slot));
    if (index < list.length) {
      if (sets != null) list[index].sets = sets.clamp(1, 20);
      if (reps != null) list[index].reps = reps.clamp(1, 999);
    }
    plan.slots[slot.name] = list;
    _setTodayPlan(plan);
  }

  void toggleHabitLink(ExerciseSlot slot) {
    final plan = todayPlan;
    final key = slot.name;
    if (plan.habitLinkedSlots.contains(key)) {
      plan.habitLinkedSlots.remove(key);
    } else {
      plan.habitLinkedSlots.add(key);
    }
    _setTodayPlan(plan);
  }

  bool isSlotComplete(ExerciseSlot slot) {
    final list = todayPlan.forSlot(slot);
    if (list.isEmpty) return false;
    return list.every((e) => e.done);
  }

  void _syncExerciseHabits(DayExercisePlan plan) {
    for (final slot in ExerciseSlot.values) {
      if (slot == ExerciseSlot.custom) continue;
      final linked = plan.habitLinkedSlots.contains(slot.name);
      final habitId = slot == ExerciseSlot.morning
          ? kMorningExerciseHabitId
          : kEveningExerciseHabitId;
      final label = slot == ExerciseSlot.morning
          ? 'Morning Exercise 🌅'
          : 'Evening Exercise 🌙';
      if (linked) {
        if (!habits.any((h) => h.id == habitId)) {
          habits.add(Habit(id: habitId, label: label));
        }
        final complete = isSlotComplete(slot);
        final h = habits.firstWhere((x) => x.id == habitId, orElse: () => habits.last);
        h.week[todayIdx] = complete;
        h.streak = h.week.where((v) => v).length;
      } else {
        habits.removeWhere((h) => h.id == habitId);
      }
    }
  }

  // ── Alarm ─────────────────────────────────────────────────
  void toggleAlarm(bool value) {
    _alarmEnabled = value;
    value ? _scheduleAlarm() : _cancelAlarm();
    _save(); notifyListeners();
  }

  void setAlarmInterval(int min) {
    _alarmIntervalMin = min.clamp(5, 240);
    if (_alarmEnabled) { _cancelAlarm(); _scheduleAlarm(); }
    _save(); notifyListeners();
  }

  void _scheduleAlarm() {
    _alarmTimer?.cancel();
    _countdownTimer?.cancel();
    _alarmNextFire = DateTime.now().add(Duration(minutes: _alarmIntervalMin));
    _alarmTimer    = Timer(Duration(minutes: _alarmIntervalMin), _fireAlarm);
    // Update countdown every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
    notifyListeners();
  }

  Future<void> _fireAlarm() async {
    if (!_alarmEnabled) return;
    final remaining = water.goal - water.glasses;
    final title = 'daily tracker 💧';
    final body  = remaining > 0
        ? 'Time to drink water! $remaining glass${remaining > 1 ? "es" : ""} left today.'
        : 'Daily water goal reached — amazing work! 🎉';

    // Push real system notification (lock screen + notification panel)
    await onNotify?.call(title, body);
    _addAlarmLog('💧', body);

    if (_alarmEnabled) _scheduleAlarm();
    notifyListeners();
  }

  void _cancelAlarm() {
    _alarmTimer?.cancel();
    _countdownTimer?.cancel();
    _alarmTimer     = null;
    _countdownTimer = null;
    _alarmNextFire  = null;
    notifyListeners();
  }

  void _onWaterLogged() {
    if (!_alarmEnabled) return;
    _cancelAlarm();
    _scheduleAlarm();
    _addAlarmLog('🥤', 'Logged a glass — reminder reset.');
    notifyListeners();
  }

  void _addAlarmLog(String icon, String msg) {
    final now  = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, "0")}:${now.minute.toString().padLeft(2, "0")}';
    alarmLog.insert(0, {'icon': icon, 'msg': msg, 'time': time});
    if (alarmLog.length > 10) alarmLog.removeLast();
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
