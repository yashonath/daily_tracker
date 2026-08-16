import '../models/exercise_models.dart';

/// Full exercise library grouped by muscle group.
/// Each exercise has sensible default sets/reps.
const List<ExerciseTemplate> kExerciseLibrary = [
  // ── CHEST ──────────────────────────────────────────────
  ExerciseTemplate(id: 'ch01', name: 'Barbell Bench Press',      muscle: MuscleGroup.chest,     defaultSets: 4, defaultReps: 8,  equipment: 'Barbell',    tip: 'Keep shoulder blades retracted and feet flat.'),
  ExerciseTemplate(id: 'ch02', name: 'Dumbbell Bench Press',     muscle: MuscleGroup.chest,     defaultSets: 3, defaultReps: 10, equipment: 'Dumbbells',  tip: 'Lower slowly to feel the stretch.'),
  ExerciseTemplate(id: 'ch03', name: 'Incline Bench Press',      muscle: MuscleGroup.chest,     defaultSets: 3, defaultReps: 10, equipment: 'Barbell',    tip: '30–45° incline targets upper chest.'),
  ExerciseTemplate(id: 'ch04', name: 'Cable Fly',                muscle: MuscleGroup.chest,     defaultSets: 3, defaultReps: 12, equipment: 'Cable',      tip: 'Squeeze at the centre for peak contraction.'),
  ExerciseTemplate(id: 'ch05', name: 'Push-Up',                  muscle: MuscleGroup.chest,     defaultSets: 3, defaultReps: 15, equipment: 'Bodyweight', tip: 'Keep core tight, elbows at 45°.'),
  ExerciseTemplate(id: 'ch06', name: 'Chest Dip',                muscle: MuscleGroup.chest,     defaultSets: 3, defaultReps: 10, equipment: 'Bodyweight', tip: 'Lean forward to target chest over triceps.'),
  ExerciseTemplate(id: 'ch07', name: 'Pec Deck Machine',         muscle: MuscleGroup.chest,     defaultSets: 3, defaultReps: 12, equipment: 'Machine',    tip: 'Control the eccentric on every rep.'),
  ExerciseTemplate(id: 'ch08', name: 'Decline Bench Press',      muscle: MuscleGroup.chest,     defaultSets: 3, defaultReps: 10, equipment: 'Barbell',    tip: 'Targets lower chest fibres.'),

  // ── BACK ───────────────────────────────────────────────
  ExerciseTemplate(id: 'bk01', name: 'Barbell Deadlift',         muscle: MuscleGroup.back,      defaultSets: 4, defaultReps: 5,  equipment: 'Barbell',    tip: 'Neutral spine; drive through the floor.'),
  ExerciseTemplate(id: 'bk02', name: 'Pull-Up',                  muscle: MuscleGroup.back,      defaultSets: 4, defaultReps: 8,  equipment: 'Bodyweight', tip: 'Full hang to chin above bar.'),
  ExerciseTemplate(id: 'bk03', name: 'Lat Pulldown',             muscle: MuscleGroup.back,      defaultSets: 3, defaultReps: 12, equipment: 'Cable',      tip: 'Pull to upper chest; avoid swinging.'),
  ExerciseTemplate(id: 'bk04', name: 'Seated Cable Row',         muscle: MuscleGroup.back,      defaultSets: 3, defaultReps: 12, equipment: 'Cable',      tip: 'Squeeze shoulder blades at peak.'),
  ExerciseTemplate(id: 'bk05', name: 'Bent-Over Barbell Row',    muscle: MuscleGroup.back,      defaultSets: 4, defaultReps: 8,  equipment: 'Barbell',    tip: 'Hinge at hips; row to lower ribcage.'),
  ExerciseTemplate(id: 'bk06', name: 'Single-Arm Dumbbell Row',  muscle: MuscleGroup.back,      defaultSets: 3, defaultReps: 10, equipment: 'Dumbbells',  tip: 'Support on bench; big elbow drive.'),
  ExerciseTemplate(id: 'bk07', name: 'T-Bar Row',                muscle: MuscleGroup.back,      defaultSets: 3, defaultReps: 10, equipment: 'Barbell',    tip: 'Chest pad keeps torso stable.'),
  ExerciseTemplate(id: 'bk08', name: 'Face Pull',                muscle: MuscleGroup.back,      defaultSets: 3, defaultReps: 15, equipment: 'Cable',      tip: 'Pull to eye level, elbows high.'),

  // ── SHOULDERS ──────────────────────────────────────────
  ExerciseTemplate(id: 'sh01', name: 'Overhead Press (Barbell)', muscle: MuscleGroup.shoulders, defaultSets: 4, defaultReps: 6,  equipment: 'Barbell',    tip: 'Bar path: slightly forward of head on way up.'),
  ExerciseTemplate(id: 'sh02', name: 'Dumbbell Lateral Raise',   muscle: MuscleGroup.shoulders, defaultSets: 4, defaultReps: 15, equipment: 'Dumbbells',  tip: 'Lead with elbow; slight forward lean.'),
  ExerciseTemplate(id: 'sh03', name: 'Arnold Press',             muscle: MuscleGroup.shoulders, defaultSets: 3, defaultReps: 10, equipment: 'Dumbbells',  tip: 'Rotate palms outward during press.'),
  ExerciseTemplate(id: 'sh04', name: 'Front Raise',              muscle: MuscleGroup.shoulders, defaultSets: 3, defaultReps: 12, equipment: 'Dumbbells',  tip: 'Raise to shoulder height; no swinging.'),
  ExerciseTemplate(id: 'sh05', name: 'Upright Row',              muscle: MuscleGroup.shoulders, defaultSets: 3, defaultReps: 12, equipment: 'Barbell',    tip: 'Keep bar close; elbows above wrists.'),
  ExerciseTemplate(id: 'sh06', name: 'Cable Lateral Raise',      muscle: MuscleGroup.shoulders, defaultSets: 3, defaultReps: 15, equipment: 'Cable',      tip: 'Cross-body cable gives constant tension.'),
  ExerciseTemplate(id: 'sh07', name: 'Rear Delt Fly',            muscle: MuscleGroup.shoulders, defaultSets: 3, defaultReps: 15, equipment: 'Dumbbells',  tip: 'Bent over; pinch rear delts.'),

  // ── BICEPS ─────────────────────────────────────────────
  ExerciseTemplate(id: 'bi01', name: 'Barbell Curl',             muscle: MuscleGroup.biceps,    defaultSets: 4, defaultReps: 10, equipment: 'Barbell',    tip: 'Elbows fixed at sides; full ROM.'),
  ExerciseTemplate(id: 'bi02', name: 'Dumbbell Hammer Curl',     muscle: MuscleGroup.biceps,    defaultSets: 3, defaultReps: 12, equipment: 'Dumbbells',  tip: 'Neutral grip; works brachialis too.'),
  ExerciseTemplate(id: 'bi03', name: 'Incline Dumbbell Curl',    muscle: MuscleGroup.biceps,    defaultSets: 3, defaultReps: 10, equipment: 'Dumbbells',  tip: 'Long-head stretch at bottom.'),
  ExerciseTemplate(id: 'bi04', name: 'Preacher Curl',            muscle: MuscleGroup.biceps,    defaultSets: 3, defaultReps: 12, equipment: 'Barbell',    tip: 'Pad eliminates momentum cheating.'),
  ExerciseTemplate(id: 'bi05', name: 'Cable Curl',               muscle: MuscleGroup.biceps,    defaultSets: 3, defaultReps: 12, equipment: 'Cable',      tip: 'Constant tension through full range.'),
  ExerciseTemplate(id: 'bi06', name: 'Concentration Curl',       muscle: MuscleGroup.biceps,    defaultSets: 3, defaultReps: 12, equipment: 'Dumbbells',  tip: 'Isolates the peak; supinate hard.'),

  // ── TRICEPS ────────────────────────────────────────────
  ExerciseTemplate(id: 'tr01', name: 'Tricep Pushdown (Cable)',  muscle: MuscleGroup.triceps,   defaultSets: 4, defaultReps: 12, equipment: 'Cable',      tip: 'Keep elbows pinned; lockout fully.'),
  ExerciseTemplate(id: 'tr02', name: 'Skull Crusher',            muscle: MuscleGroup.triceps,   defaultSets: 3, defaultReps: 10, equipment: 'Barbell',    tip: 'Lower to forehead; extend fully.'),
  ExerciseTemplate(id: 'tr03', name: 'Overhead Tricep Extension',muscle: MuscleGroup.triceps,   defaultSets: 3, defaultReps: 12, equipment: 'Dumbbells',  tip: 'Stretches long head maximally.'),
  ExerciseTemplate(id: 'tr04', name: 'Close-Grip Bench Press',   muscle: MuscleGroup.triceps,   defaultSets: 3, defaultReps: 8,  equipment: 'Barbell',    tip: 'Shoulder-width grip; elbows tucked.'),
  ExerciseTemplate(id: 'tr05', name: 'Tricep Dip',               muscle: MuscleGroup.triceps,   defaultSets: 3, defaultReps: 10, equipment: 'Bodyweight', tip: 'Upright torso to isolate triceps.'),
  ExerciseTemplate(id: 'tr06', name: 'Kickback',                 muscle: MuscleGroup.triceps,   defaultSets: 3, defaultReps: 12, equipment: 'Dumbbells',  tip: 'Upper arm parallel to floor.'),

  // ── CORE ───────────────────────────────────────────────
  ExerciseTemplate(id: 'co01', name: 'Plank',                    muscle: MuscleGroup.core,      defaultSets: 3, defaultReps: 45, equipment: 'Bodyweight', tip: 'Squeeze glutes; neutral spine. Reps = seconds.', isTime: true),
  ExerciseTemplate(id: 'co02', name: 'Cable Crunch',             muscle: MuscleGroup.core,      defaultSets: 3, defaultReps: 15, equipment: 'Cable',      tip: 'Round the spine; flex the abs.'),
  ExerciseTemplate(id: 'co03', name: 'Hanging Knee Raise',       muscle: MuscleGroup.core,      defaultSets: 3, defaultReps: 15, equipment: 'Bodyweight', tip: 'Posterior tilt at the top.'),
  ExerciseTemplate(id: 'co04', name: 'Ab Wheel Rollout',         muscle: MuscleGroup.core,      defaultSets: 3, defaultReps: 10, equipment: 'Ab Wheel',   tip: 'Brace hard; prevent lumbar extension.'),
  ExerciseTemplate(id: 'co05', name: 'Russian Twist',            muscle: MuscleGroup.core,      defaultSets: 3, defaultReps: 20, equipment: 'Bodyweight', tip: 'Rotate torso, not just arms.'),
  ExerciseTemplate(id: 'co06', name: 'Side Plank',               muscle: MuscleGroup.core,      defaultSets: 3, defaultReps: 30, equipment: 'Bodyweight', tip: 'Hips high; oblique squeeze. Reps = seconds.', isTime: true),
  ExerciseTemplate(id: 'co07', name: 'Dead Bug',                 muscle: MuscleGroup.core,      defaultSets: 3, defaultReps: 10, equipment: 'Bodyweight', tip: 'Press lower back into floor throughout.'),
  ExerciseTemplate(id: 'co08', name: 'Dragon Flag',              muscle: MuscleGroup.core,      defaultSets: 3, defaultReps: 6,  equipment: 'Bodyweight', tip: 'Advanced – full body tension required.'),

  // ── LEGS ───────────────────────────────────────────────
  ExerciseTemplate(id: 'lg01', name: 'Barbell Back Squat',       muscle: MuscleGroup.legs,      defaultSets: 4, defaultReps: 6,  equipment: 'Barbell',    tip: 'Chest up; knees track over toes.'),
  ExerciseTemplate(id: 'lg02', name: 'Leg Press',                muscle: MuscleGroup.legs,      defaultSets: 4, defaultReps: 12, equipment: 'Machine',    tip: 'Full depth; don\'t lock out fully.'),
  ExerciseTemplate(id: 'lg03', name: 'Romanian Deadlift',        muscle: MuscleGroup.legs,      defaultSets: 3, defaultReps: 10, equipment: 'Barbell',    tip: 'Hinge, not squat; feel the hamstring.'),
  ExerciseTemplate(id: 'lg04', name: 'Leg Curl (Machine)',       muscle: MuscleGroup.legs,      defaultSets: 3, defaultReps: 12, equipment: 'Machine',    tip: 'Full curl; pause at peak.'),
  ExerciseTemplate(id: 'lg05', name: 'Leg Extension',            muscle: MuscleGroup.legs,      defaultSets: 3, defaultReps: 15, equipment: 'Machine',    tip: 'Squeeze quads at top; control descent.'),
  ExerciseTemplate(id: 'lg06', name: 'Walking Lunge',            muscle: MuscleGroup.legs,      defaultSets: 3, defaultReps: 12, equipment: 'Dumbbells',  tip: '12 per leg; knee grazes floor.'),
  ExerciseTemplate(id: 'lg07', name: 'Bulgarian Split Squat',    muscle: MuscleGroup.legs,      defaultSets: 3, defaultReps: 10, equipment: 'Dumbbells',  tip: 'Rear foot elevated; long stride.'),
  ExerciseTemplate(id: 'lg08', name: 'Calf Raise (Standing)',    muscle: MuscleGroup.legs,      defaultSets: 4, defaultReps: 20, equipment: 'Machine',    tip: 'Full stretch at bottom; squeeze at top.'),
  ExerciseTemplate(id: 'lg09', name: 'Hack Squat',               muscle: MuscleGroup.legs,      defaultSets: 3, defaultReps: 10, equipment: 'Machine',    tip: 'Feet high = more hamstring recruitment.'),
  ExerciseTemplate(id: 'lg10', name: 'Nordic Hamstring Curl',    muscle: MuscleGroup.legs,      defaultSets: 3, defaultReps: 6,  equipment: 'Bodyweight', tip: 'Eccentric only is fine to start.'),

  // ── GLUTES ─────────────────────────────────────────────
  ExerciseTemplate(id: 'gl01', name: 'Barbell Hip Thrust',       muscle: MuscleGroup.glutes,    defaultSets: 4, defaultReps: 12, equipment: 'Barbell',    tip: 'Chin down; drive through heels.'),
  ExerciseTemplate(id: 'gl02', name: 'Cable Kickback',           muscle: MuscleGroup.glutes,    defaultSets: 3, defaultReps: 15, equipment: 'Cable',      tip: 'Squeeze glute at peak; control back.'),
  ExerciseTemplate(id: 'gl03', name: 'Sumo Squat',               muscle: MuscleGroup.glutes,    defaultSets: 3, defaultReps: 12, equipment: 'Dumbbells',  tip: 'Wide stance; toes out; drive knees out.'),
  ExerciseTemplate(id: 'gl04', name: 'Glute Bridge',             muscle: MuscleGroup.glutes,    defaultSets: 3, defaultReps: 15, equipment: 'Bodyweight', tip: 'Posterior pelvic tilt at the top.'),
  ExerciseTemplate(id: 'gl05', name: 'Donkey Kick',              muscle: MuscleGroup.glutes,    defaultSets: 3, defaultReps: 15, equipment: 'Bodyweight', tip: 'Keep hips square; squeeze at peak.'),
  ExerciseTemplate(id: 'gl06', name: 'Step-Up',                  muscle: MuscleGroup.glutes,    defaultSets: 3, defaultReps: 12, equipment: 'Dumbbells',  tip: 'Drive through the elevated heel.'),

  // ── CARDIO ─────────────────────────────────────────────
  ExerciseTemplate(id: 'ca01', name: 'Running',                  muscle: MuscleGroup.cardio,    defaultSets: 1, defaultReps: 30, equipment: 'None',       tip: 'Reps = minutes. Zone 2 HR for fat burn.', isTime: true),
  ExerciseTemplate(id: 'ca02', name: 'Cycling',                  muscle: MuscleGroup.cardio,    defaultSets: 1, defaultReps: 30, equipment: 'Bike',       tip: 'Reps = minutes. Steady state or intervals.', isTime: true),
  ExerciseTemplate(id: 'ca03', name: 'Jump Rope',                muscle: MuscleGroup.cardio,    defaultSets: 5, defaultReps: 3,  equipment: 'Jump Rope',  tip: 'Reps = minutes. Rest 30s between sets.', isTime: true),
  ExerciseTemplate(id: 'ca04', name: 'Burpee',                   muscle: MuscleGroup.cardio,    defaultSets: 4, defaultReps: 15, equipment: 'Bodyweight', tip: 'Full hip extension at the top.'),
  ExerciseTemplate(id: 'ca05', name: 'Rowing Machine',           muscle: MuscleGroup.cardio,    defaultSets: 1, defaultReps: 20, equipment: 'Machine',    tip: 'Reps = minutes. Legs, hips, arms sequence.', isTime: true),
  ExerciseTemplate(id: 'ca06', name: 'Stair Climber',            muscle: MuscleGroup.cardio,    defaultSets: 1, defaultReps: 20, equipment: 'Machine',    tip: 'Reps = minutes. Don\'t hold rails.', isTime: true),
  ExerciseTemplate(id: 'ca07', name: 'HIIT Sprint Intervals',    muscle: MuscleGroup.cardio,    defaultSets: 8, defaultReps: 1,  equipment: 'None',       tip: '20s sprint / 40s rest per set.'),
  ExerciseTemplate(id: 'ca08', name: 'Swimming',                 muscle: MuscleGroup.cardio,    defaultSets: 1, defaultReps: 30, equipment: 'Pool',       tip: 'Reps = minutes. Mix strokes for full body.', isTime: true),
];

/// Get all exercises for a muscle group.
List<ExerciseTemplate> forMuscle(MuscleGroup m) =>
    kExerciseLibrary.where((e) => e.muscle == m).toList();
