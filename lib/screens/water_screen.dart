import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/common.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});
  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _fillCtrl;
  late Animation<double> _fillAnim;
  double _targetFill = 0;
  final _weightCtrl = TextEditingController(text: '70');
  bool _useKg = true;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _fillCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fillAnim = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOut));
  }

  void _updateFill(double target) {
    _fillAnim = Tween<double>(begin: _fillAnim.value, end: target)
        .animate(CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOut));
    _fillCtrl
      ..reset()
      ..forward();
    _targetFill = target;
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _fillCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1A19) : Colors.white;
    final surface2 = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final text2 = isDark ? const Color(0xFF78776E) : const Color(0xFF78776E);
    final text3 = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    final border = isDark ? const Color(0x14FFFFFF) : const Color(0x14000000);

    return TrackerScaffold(
      title: 'daily.track',
      body: Consumer<AppProvider>(
        builder: (ctx, p, _) {
          final w = p.water;
          final pct = w.pct;
          WidgetsBinding.instance.addPostFrameCallback((_) { if (_targetFill != pct) _updateFill(pct); });

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [

              // ── Weight panel ──────────────────────────────
              _Panel(
                isDark: isDark, surface: surface, border: border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(Icons.monitor_weight_outlined, size: 15, color: text3),
                          const SizedBox(width: 6),
                          Text('Body weight', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: text)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(99)),
                            child: Text('${w.weightKg.toStringAsFixed(1)} kg',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF2563EB), fontFamily: 'monospace')),
                          ),
                        ]),
                        // kg / lbs toggle
                        _UnitToggle(useKg: _useKg, onToggle: (v) {
                          setState(() {
                            _useKg = v;
                            _weightCtrl.text = v ? w.weightKg.toStringAsFixed(1) : (w.weightKg * 2.2046).toStringAsFixed(1);
                          });
                          p.setWeightUnit(v);
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'monospace'),
                            decoration: InputDecoration(
                              hintText: _useKg ? '70' : '154',
                              hintStyle: TextStyle(color: text3),
                              suffixText: _useKg ? 'kg' : 'lbs',
                              suffixStyle: TextStyle(fontSize: 12, color: text3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            final raw = double.tryParse(_weightCtrl.text) ?? 70;
                            final kg = _useKg ? raw : raw / 2.2046;
                            p.applyWeight(kg);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Goal updated to ${p.water.goal} glasses'), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                            decoration: BoxDecoration(color: text, borderRadius: BorderRadius.circular(9)),
                            child: Row(children: [Icon(Icons.check_rounded, size: 16, color: isDark ? const Color(0xFF111110) : Colors.white), const SizedBox(width: 4), Text('Apply', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF111110) : Colors.white))]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Recommendation box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          InfoRow(label: 'recommended intake', value: '${w.recommendedMl.toLocaleString()} ml'),
                          const SizedBox(height: 6),
                          InfoRow(label: 'glasses needed', value: '${w.recommendedGlasses} × 250 ml'),
                          const SizedBox(height: 6),
                          InfoRow(label: 'formula', value: '${w.weightKg.toStringAsFixed(0)} kg × 30 ml'),
                          const SizedBox(height: 8),
                          ProgressBar(value: (w.goal * 250) / w.recommendedMl.clamp(1, 9999), color: const Color(0xFF2563EB)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body + stats ──────────────────────────────
              _Panel(
                isDark: isDark, surface: surface, border: border,
                child: Column(
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${w.glasses}', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w400, color: text, height: 1, fontFamily: 'monospace')),
                          Text('/ ${w.goal} glasses', style: TextStyle(fontSize: 13, color: text3)),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('goal', style: TextStyle(fontSize: 11, color: text3)),
                          Row(children: [
                            _GoalBtn(icon: Icons.remove, onTap: () => p.changeWaterGoal(-1)),
                            const SizedBox(width: 8),
                            Text('${w.goal}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: text, fontFamily: 'monospace')),
                            const SizedBox(width: 8),
                            _GoalBtn(icon: Icons.add, onTap: () => p.changeWaterGoal(1)),
                          ]),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Body + stats row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Animated body
                        AnimatedBuilder(
                          animation: Listenable.merge([_waveCtrl, _fillAnim]),
                          builder: (_, __) => SizedBox(
                            width: 100, height: 220,
                            child: CustomPaint(painter: _BodyPainter(fill: _fillAnim.value, wave: _waveCtrl.value, isDark: isDark)),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatRow(label: 'consumed', value: '${w.consumedMl.toLocaleString()} ml', color: const Color(0xFF60A5FA)),
                              const SizedBox(height: 10),
                              _StatRow(label: 'remaining', value: '${w.remainingMl.toLocaleString()} ml', color: surface2, borderColor: border),
                              const SizedBox(height: 10),
                              _StatRow(label: 'progress', value: '${(w.pct * 100).round()}%', color: const Color(0xFF34D399)),
                              const SizedBox(height: 14),
                              Divider(color: border, height: 1),
                              const SizedBox(height: 10),
                              Text(_hint(w.pct), style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Glasses grid
                    GridView.builder(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, mainAxisSpacing: 6, crossAxisSpacing: 6),
                      itemCount: w.goal,
                      itemBuilder: (_, i) {
                        final filled = i < w.glasses;
                        return GestureDetector(
                          onTap: () => p.setGlassesTo(i < w.glasses ? i : i + 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: filled ? const Color(0xFFEFF6FF) : surface2,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: filled ? const Color(0xFF2563EB).withOpacity(0.25) : border, width: 0.5),
                            ),
                            child: Icon(Icons.local_drink_outlined, size: 18, color: filled ? const Color(0xFF1E40AF) : text3),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    // Action buttons
                    Row(children: [
                      Expanded(
                        child: _ActionBtn(label: '+1 glass', icon: Icons.water_drop_rounded, primary: true, isDark: isDark, onTap: () => p.logWater(1)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionBtn(label: 'Remove', icon: Icons.remove_rounded, primary: false, isDark: isDark, onTap: () => p.logWater(-1)),
                      ),
                    ]),
                    if (w.pct >= 1)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF0FBF6), borderRadius: BorderRadius.circular(9), border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.15))),
                        child: const Center(child: Text('Goal reached — great work today! 🎉', style: TextStyle(fontSize: 13, color: Color(0xFF1D9E75)))),
                      ),
                  ],
                ),
              ),

              // ── Alarm panel ───────────────────────────────
              _AlarmPanel(isDark: isDark, surface: surface, border: border),

            ],
          );
        },
      ),
    );
  }

  String _hint(double pct) {
    if (pct >= 1) return 'Goal reached! 🎉';
    if (pct >= 0.75) return 'Almost there!';
    if (pct >= 0.5) return 'Halfway there!';
    if (pct >= 0.25) return 'Good start!';
    return 'Stay hydrated!';
  }
}

// ── Body painter ────────────────────────────────────────
class _BodyPainter extends CustomPainter {
  final double fill;
  final double wave;
  final bool isDark;

  _BodyPainter({required this.fill, required this.wave, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width, H = size.height;
    final bodyColor = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);
    final borderColor = isDark ? const Color(0x22FFFFFF) : const Color(0x22000000);
    final waterTop = const Color(0xFF60A5FA);
    final waterBot = const Color(0xFF1D4ED8);

    // Body parts
    final parts = _bodyParts(W, H);
    final bodyPaint = Paint()..color = bodyColor;
    final borderPaint = Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 1;

    for (final path in parts) {
      canvas.drawPath(path, bodyPaint);
      canvas.drawPath(path, borderPaint);
    }

    // Clip to body shape
    final clipPath = Path();
    for (final p in parts) clipPath.addPath(p, Offset.zero);
    canvas.save();
    canvas.clipPath(clipPath);

    // Water fill
    final fillY = H * (1 - fill);
    final waterPaint = Paint()
      ..shader = LinearGradient(colors: [waterTop, waterBot], begin: Alignment.topCenter, end: Alignment.bottomCenter)
          .createShader(Rect.fromLTWH(0, fillY, W, H - fillY));

    final waterPath = Path();
    waterPath.moveTo(0, fillY);
    for (double x = 0; x <= W; x++) {
      final y = fillY + sin((x / W * 2 * pi) + (wave * 2 * pi)) * 4;
      waterPath.lineTo(x, y);
    }
    waterPath.lineTo(W, H);
    waterPath.lineTo(0, H);
    waterPath.close();

    if (fill > 0.01) canvas.drawPath(waterPath, waterPaint..style = PaintingStyle.fill..shader = LinearGradient(colors: [waterTop.withOpacity(0.85), waterBot.withOpacity(0.85)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, fillY, W, H - fillY)));

    canvas.restore();

    // Redraw borders on top
    for (final path in parts) canvas.drawPath(path, borderPaint);

    // Percentage label
    if (fill > 0) {
      final pct = '${(fill * 100).round()}%';
      final textStyle = TextStyle(color: fill > 0.5 ? Colors.white : (isDark ? const Color(0xFF78776E) : const Color(0xFF78776E)), fontSize: 11, fontWeight: FontWeight.w500);
      final tp = TextPainter(text: TextSpan(text: pct, style: textStyle), textDirection: TextDirection.ltr)..layout();
      final labelY = (H * (1 - fill) - 16).clamp(8.0, H - 16);
      tp.paint(canvas, Offset((W - tp.width) / 2, labelY));
    }
  }

  List<Path> _bodyParts(double W, double H) {
    final head = Path()..addOval(Rect.fromCircle(center: Offset(W * 0.5, H * 0.09), radius: W * 0.18));
    final neck = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(W * 0.44, H * 0.17, W * 0.12, H * 0.05), const Radius.circular(3)));
    final torso = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(W * 0.24, H * 0.21, W * 0.52, H * 0.3), const Radius.circular(10)));
    final lArm = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(W * 0.04, H * 0.22, W * 0.18, H * 0.25), const Radius.circular(9)));
    final rArm = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(W * 0.78, H * 0.22, W * 0.18, H * 0.25), const Radius.circular(9)));
    final lLeg = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(W * 0.24, H * 0.49, W * 0.22, H * 0.47), const Radius.circular(9)));
    final rLeg = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(W * 0.54, H * 0.49, W * 0.22, H * 0.47), const Radius.circular(9)));
    return [head, neck, torso, lArm, rArm, lLeg, rLeg];
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.fill != fill || old.wave != wave;
}

// ── Helper widgets ───────────────────────────────────────
class _Panel extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color surface;
  final Color border;
  const _Panel({required this.child, required this.isDark, required this.surface, required this.border});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
    child: child,
  );
}

class _GoalBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GoalBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface2 = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(color: surface2, shape: BoxShape.circle, border: Border.all(color: isDark ? const Color(0x22FFFFFF) : const Color(0x22000000))),
        child: Icon(icon, size: 18, color: text),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color? borderColor;
  const _StatRow({required this.label, required this.value, required this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final text3 = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: borderColor != null ? Border.all(color: borderColor!) : null)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace'))),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: text, fontFamily: 'monospace')),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final bool isDark;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.primary, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final bg = isDark ? const Color(0xFF111110) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: primary ? text : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: isDark ? const Color(0x22FFFFFF) : const Color(0x22000000)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: primary ? bg : (isDark ? const Color(0xFF78776E) : const Color(0xFF78776E))),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: primary ? bg : (isDark ? const Color(0xFF78776E) : const Color(0xFF78776E)))),
        ]),
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final bool useKg;
  final ValueChanged<bool> onToggle;
  const _UnitToggle({required this.useKg, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface2 = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);
    final surface = isDark ? const Color(0xFF1A1A19) : Colors.white;
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final text3 = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          _UnitChip(label: 'kg', active: useKg, surface: surface, text: text, text3: text3, onTap: () => onToggle(true)),
          _UnitChip(label: 'lbs', active: !useKg, surface: surface, text: text, text3: text3, onTap: () => onToggle(false)),
        ],
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color surface, text, text3;
  final VoidCallback onTap;
  const _UnitChip({required this.label, required this.active, required this.surface, required this.text, required this.text3, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: active ? surface : Colors.transparent, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w500 : FontWeight.w400, color: active ? text : text3)),
    ),
  );
}

// ── Alarm panel ─────────────────────────────────────────
class _AlarmPanel extends StatefulWidget {
  final bool isDark;
  final Color surface;
  final Color border;
  const _AlarmPanel({required this.isDark, required this.surface, required this.border});
  @override
  State<_AlarmPanel> createState() => _AlarmPanelState();
}

class _AlarmPanelState extends State<_AlarmPanel> {
  final _intervals = [30, 60, 90, 120];
  final _intervalLabels = ['30 min', '1 hr', '1.5 hr', '2 hr'];
  final _customCtrl = TextEditingController(text: '60');

  @override
  void dispose() { _customCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final surface = widget.surface;
    final border = widget.border;
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final text2 = isDark ? const Color(0xFF78776E) : const Color(0xFF78776E);
    final text3 = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    final surface2 = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);

    return Consumer<AppProvider>(
      builder: (ctx, p, _) {
        final enabled = p.alarmEnabled;
        final interval = p.alarmIntervalMin;
        final next = p.alarmNextFire;

        String nextStr = '';
        if (enabled && next != null) {
          final diff = next.difference(DateTime.now());
          if (diff.isNegative) {
            nextStr = 'soon';
          } else {
            final m = diff.inMinutes;
            final s = diff.inSeconds % 60;
            nextStr = '${m}m ${s.toString().padLeft(2, '0')}s';
          }
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.notifications_outlined, size: 15, color: text3),
                    const SizedBox(width: 6),
                    Text('Drink reminders', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: text)),
                  ]),
                  Switch.adaptive(
                    value: enabled,
                    onChanged: (v) async {
                      if (v) {
                        // On Android, local notifications need no extra permission for basic alerts
                        p.toggleAlarm(true);
                      } else {
                        p.toggleAlarm(false);
                      }
                    },
                    activeColor: const Color(0xFF2563EB),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Interval chips
              Wrap(
                spacing: 6, runSpacing: 6,
                children: List.generate(_intervals.length, (i) {
                  final active = interval == _intervals[i];
                  return GestureDetector(
                    onTap: () { p.setAlarmInterval(_intervals[i]); _customCtrl.text = _intervals[i].toString(); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF2563EB) : Colors.transparent,
                        border: Border.all(color: active ? const Color(0xFF2563EB) : (isDark ? const Color(0x22FFFFFF) : const Color(0x22000000))),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(_intervalLabels[i], style: TextStyle(fontSize: 11, color: active ? Colors.white : text3, fontWeight: active ? FontWeight.w500 : FontWeight.w400)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              // Custom interval
              Row(children: [
                Text('or custom:', style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace')),
                const SizedBox(width: 8),
                SizedBox(
                  width: 65,
                  child: TextField(
                    controller: _customCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                    decoration: InputDecoration(hintText: '60', hintStyle: TextStyle(color: text3), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                    onSubmitted: (v) { final min = int.tryParse(v)?.clamp(5, 240) ?? 60; p.setAlarmInterval(min); },
                  ),
                ),
                const SizedBox(width: 6),
                Text('min', style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace')),
              ]),
              const SizedBox(height: 12),
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: enabled ? const Color(0xFF22C55E) : text3,
                          boxShadow: enabled ? [BoxShadow(color: const Color(0xFF22C55E).withOpacity(0.3), blurRadius: 6)] : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(enabled ? 'Reminders on — every $interval min' : 'Reminders off', style: TextStyle(fontSize: 12, color: text2)),
                    ]),
                    if (enabled && nextStr.isNotEmpty)
                      Text(nextStr, style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontFamily: 'monospace', fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              // Log
              if (p.alarmLog.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...p.alarmLog.take(5).map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(7)),
                    child: Row(children: [
                      Text(l['time'] ?? '', style: TextStyle(fontSize: 10, color: text3, fontFamily: 'monospace')),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${l['icon']} ${l['msg']}', style: TextStyle(fontSize: 11, color: text2))),
                    ]),
                  ),
                )),
              ],
            ],
          ),
        );
      },
    );
  }
}

extension IntExt on int {
  String toLocaleString() {
    final s = toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
