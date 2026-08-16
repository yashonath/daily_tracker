import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _timeline = 'week';
  String _graphStyle = 'doughnut';
  DateTime? _pickedDate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1A19) : Colors.white;
    final surface2 = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final text2 = isDark ? const Color(0xFF78776E) : const Color(0xFF78776E);
    final text3 = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    final border = isDark ? const Color(0x14FFFFFF) : const Color(0x14000000);
    final gridColor = isDark ? const Color(0x0FFFFFFF) : const Color(0x0F000000);

    return TrackerScaffold(
      title: 'daily.track',
      body: Consumer<AppProvider>(
        builder: (ctx, p, _) {
          final pts = p.historyForRange(_timeline);
          final labels = _labels(pts, _timeline);
          final habitData = pts.map((h) => h.habitPct.toDouble()).toList();
          final taskData = pts.map((h) => h.tasksTotal > 0 ? (h.tasksDone / h.tasksTotal * 100) : 0.0).toList();
          final waterData = pts.map((h) => h.waterGlasses.toDouble()).toList();

          // ── Live stats from actual user input ──
          final habPct = p.habitCompletionPct;
          final tdDone = p.tasksDone;
          final wPct   = p.waterPct;

          return ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              // ── Toolbar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        PillGroup(options: const ['Week', 'Month', 'Year'], selected: ['week','month','year'].indexOf(_timeline), onSelect: (i) => setState(() => _timeline = ['week','month','year'][i])),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now());
                            setState(() => _pickedDate = d);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(7), border: Border.all(color: border)),
                            child: Row(children: [Icon(Icons.calendar_today_outlined, size: 13, color: text3), const SizedBox(width: 5), Text(_pickedDate != null ? '${_pickedDate!.month}/${_pickedDate!.day}' : 'Date', style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace'))]),
                          ),
                        ),
                        if (_pickedDate != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(onTap: () => setState(() => _pickedDate = null), child: Icon(Icons.close_rounded, size: 16, color: text3)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Graph style
                    Row(
                      children: [
                        Text('Chart:', style: TextStyle(fontSize: 11, color: text3)),
                        const SizedBox(width: 8),
                        PillGroup(
                          options: const ['Donut', 'Bars', 'Line', 'Bar chart'],
                          selected: ['doughnut', 'progressbar', 'line', 'bar'].indexOf(_graphStyle),
                          onSelect: (i) => setState(() => _graphStyle = ['doughnut', 'progressbar', 'line', 'bar'][i]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Date view banner
              if (_pickedDate != null) _DateBanner(date: _pickedDate!, isDark: isDark, surface: surface, border: border, text2: text2),

              // ── Summary stats ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _StatCard(label: 'Habit rate', value: p.habits.isEmpty ? '—' : '$habPct%',             icon: Icons.repeat_rounded,    iconBg: const Color(0xFFEFF6FF), iconColor: const Color(0xFF2563EB), isDark: isDark, surface: surface, border: border, text: text, text3: text3),
                    const SizedBox(width: 8),
                    _StatCard(label: 'Tasks done', value: p.todos.isEmpty  ? '—' : '$tdDone/${p.tasksTotal}', icon: Icons.checklist_rounded, iconBg: const Color(0xFFF0FDF4), iconColor: const Color(0xFF16A34A), isDark: isDark, surface: surface, border: border, text: text, text3: text3),
                    const SizedBox(width: 8),
                    _StatCard(label: 'Hydration',  value: '$wPct%',                                        icon: Icons.water_drop_rounded, iconBg: const Color(0xFFFEF2F2), iconColor: const Color(0xFFDC2626), isDark: isDark, surface: surface, border: border, text: text, text3: text3),
                    const SizedBox(width: 8),
                    _StatCard(label: 'Entries',    value: '${p.journal.length}',                            icon: Icons.book_outlined,      iconBg: const Color(0xFFF4F4F2), iconColor: const Color(0xFF78776E), isDark: isDark, surface: surface, border: border, text: text, text3: text3),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Habits chart ──
              _ChartCard(
                title: 'Habits', icon: Icons.repeat_rounded, titleColor: const Color(0xFF2563EB),
                sub: 'today\'s completion', surface: surface, border: border, text: text, text3: text3,
                child: pts.isEmpty || p.habits.isEmpty
                    ? _EmptyChart('Log some habits to see data here', text3)
                    : _buildChart(habitData, labels, const Color(0xFF2563EB), _graphStyle, p, 'habits', surface2, text, text3, gridColor, isDark),
              ),

              // ── Tasks chart ──
              _ChartCard(
                title: 'Tasks', icon: Icons.checklist_rounded, titleColor: const Color(0xFF16A34A),
                sub: 'completion %', surface: surface, border: border, text: text, text3: text3,
                child: pts.isEmpty || p.todos.isEmpty
                    ? _EmptyChart('Add some tasks to see data here', text3)
                    : _buildChart(taskData, labels, const Color(0xFF16A34A), _graphStyle, p, 'tasks', surface2, text, text3, gridColor, isDark),
              ),

              // ── Water chart ──
              _ChartCard(
                title: 'Water', icon: Icons.water_drop_rounded, titleColor: const Color(0xFFDC2626),
                sub: 'glasses / day', surface: surface, border: border, text: text, text3: text3,
                child: pts.isEmpty
                    ? _EmptyChart('Log water intake to see data here', text3)
                    : _buildChart(waterData, labels, const Color(0xFFDC2626), _graphStyle, p, 'water', surface2, text, text3, gridColor, isDark),
              ),

              // ── Heatmap ──
              _ChartCard(
                title: 'Activity', icon: Icons.calendar_month_rounded, titleColor: text,
                sub: 'habit heatmap', surface: surface, border: border, text: text, text3: text3,
                child: pts.isEmpty
                    ? _EmptyChart('Start tracking to build your activity map', text3)
                    : _HeatmapWidget(pts: pts, surface2: surface2, text3: text3),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _labels(List<DayHistory> pts, String tl) {
    if (tl == 'week') return pts.map((h) => ['M','T','W','T','F','S','S'][h.date.weekday - 1]).toList();
    if (tl == 'month') return pts.map((h) => '${h.date.day}').toList();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return pts.map((h) => months[h.date.month - 1]).toList();
  }

  Widget _buildChart(List<double> data, List<String> labels, Color color, String style, AppProvider p, String type, Color surface2, Color text, Color text3, Color gridColor, bool isDark) {
    if (style == 'doughnut') return _DonutChart(data: data, color: color, type: type, p: p, text: text, text3: text3);
    if (style == 'progressbar') return _ProgBarChart(data: data, labels: labels, color: color, text: text, text3: text3, surface2: surface2);
    if (style == 'line') return _LineChart(data: data, labels: labels, color: color, gridColor: gridColor, text3: text3, isDark: isDark);
    return _BarChart(data: data, labels: labels, color: color, gridColor: gridColor, text3: text3, isDark: isDark);
  }
}

// ── Donut chart ─────────────────────────────────────────
class _DonutChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final String type;
  final AppProvider p;
  final Color text, text3;

  const _DonutChart({required this.data, required this.color, required this.type, required this.p, required this.text, required this.text3});

  @override
  Widget build(BuildContext context) {
    double done = 0, total = 0;
    List<PieChartSectionData> sections = [];
    String centerVal = '';

    if (type == 'habits') {
      final avg = data.isEmpty ? 0 : data.reduce((a, b) => a + b) / data.length;
      done = avg.toDouble(); total = (100 - avg).toDouble();
      centerVal = '${avg.round()}%';
    } else if (type == 'tasks') {
      final high = p.todos.where((t) => t.priority == TaskPriority.high).length.toDouble();
      final med = p.todos.where((t) => t.priority == TaskPriority.med).length.toDouble();
      final low = p.todos.where((t) => t.priority == TaskPriority.low).length.toDouble();
      final tot = (high + med + low).clamp(1, 9999);
      sections = [
        PieChartSectionData(value: high, color: const Color(0xFFDC2626), radius: 30, showTitle: false),
        PieChartSectionData(value: med, color: const Color(0xFFD97706), radius: 30, showTitle: false),
        PieChartSectionData(value: low.clamp(0.01, 999), color: const Color(0xFF16A34A), radius: 30, showTitle: false),
      ];
      centerVal = '${p.todos.where((t) => t.done).length}/${p.todos.length}';
    } else {
      final avg = data.isEmpty ? 0 : data.reduce((a, b) => a + b) / data.length;
      done = avg.toDouble(); total = (p.water.goal - avg).clamp(0, 99).toDouble();
      centerVal = '${(avg / p.water.goal * 100).round()}%';
    }

    if (sections.isEmpty) {
      sections = [
        PieChartSectionData(value: done.clamp(0.01, 999), color: color, radius: 30, showTitle: false),
        PieChartSectionData(value: total.clamp(0.01, 999), color: color.withOpacity(0.15), radius: 30, showTitle: false),
      ];
    }

    return SizedBox(
      height: 140,
      child: Row(
        children: [
          SizedBox(
            width: 130, height: 130,
            child: Stack(alignment: Alignment.center, children: [
              PieChart(PieChartData(sections: sections, centerSpaceRadius: 42, sectionsSpace: 2, startDegreeOffset: -90)),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(centerVal, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: text, fontFamily: 'monospace')),
                Text(type == 'tasks' ? 'done' : 'avg', style: TextStyle(fontSize: 9, color: text3)),
              ]),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(child: _legend(type, p, text, text3)),
        ],
      ),
    );
  }

  Widget _legend(String type, AppProvider p, Color text, Color text3) {
    if (type == 'habits') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: p.habits.map((h) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(h.label, style: TextStyle(fontSize: 12, color: text), overflow: TextOverflow.ellipsis)),
            Text('${h.streak}d', style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace')),
          ]),
        )).toList(),
      );
    } else if (type == 'tasks') {
      final high = p.todos.where((t) => t.priority == TaskPriority.high);
      final med = p.todos.where((t) => t.priority == TaskPriority.med);
      final low = p.todos.where((t) => t.priority == TaskPriority.low);
      return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _LegendItem(color: const Color(0xFFDC2626), label: 'High', val: '${high.where((t) => t.done).length}/${high.length}', text: text, text3: text3),
        const SizedBox(height: 8),
        _LegendItem(color: const Color(0xFFD97706), label: 'Medium', val: '${med.where((t) => t.done).length}/${med.length}', text: text, text3: text3),
        const SizedBox(height: 8),
        _LegendItem(color: const Color(0xFF16A34A), label: 'Low', val: '${low.where((t) => t.done).length}/${low.length}', text: text, text3: text3),
      ]);
    } else {
      final avg = data.isEmpty ? 0 : data.reduce((a, b) => a + b) / data.length;
      return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _LegendItem(color: color, label: 'Consumed', val: '${avg.toStringAsFixed(1)}gl', text: text, text3: text3),
        const SizedBox(height: 8),
        _LegendItem(color: color.withOpacity(0.2), label: 'Remaining', val: '${(p.water.goal - avg).clamp(0,99).toStringAsFixed(1)}gl', text: text, text3: text3),
      ]);
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label, val;
  final Color text, text3;
  const _LegendItem({required this.color, required this.label, required this.val, required this.text, required this.text3});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 8),
    Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: text))),
    Text(val, style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace')),
  ]);
}

// ── Progress bar chart ───────────────────────────────────
class _ProgBarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final Color color;
  final Color text, text3, surface2;

  const _ProgBarChart({required this.data, required this.labels, required this.color, required this.text, required this.text3, required this.surface2});

  @override
  Widget build(BuildContext context) {
    final show = data.length > 7 ? data.sublist(data.length - 7) : data;
    final showLabels = labels.length > 7 ? labels.sublist(labels.length - 7) : labels;
    return Column(
      children: List.generate(show.length, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(width: 30, child: Text(showLabels[i], style: TextStyle(fontSize: 10, color: text3, fontFamily: 'monospace'))),
          const SizedBox(width: 8),
          Expanded(child: ProgressBar(value: show[i] / 100, color: color)),
          const SizedBox(width: 8),
          SizedBox(width: 34, child: Text('${show[i].round()}%', style: TextStyle(fontSize: 10, color: text3, fontFamily: 'monospace'), textAlign: TextAlign.right)),
        ]),
      )),
    );
  }
}

// ── Line chart ───────────────────────────────────────────
class _LineChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final Color color, gridColor, text3;
  final bool isDark;

  const _LineChart({required this.data, required this.labels, required this.color, required this.gridColor, required this.text3, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox(height: 150);
    final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final step = data.length > 10 ? (data.length / 6).ceil() : 1;

    return SizedBox(
      height: 160,
      child: LineChart(LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 0.5)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, interval: step.toDouble(),
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= labels.length) return const SizedBox();
              return Text(labels[i], style: TextStyle(fontSize: 9, color: text3));
            },
          )),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots, isCurved: true, color: color, barWidth: 2,
            dotData: FlDotData(show: data.length <= 10),
            belowBarData: BarAreaData(show: true, color: color.withOpacity(0.08)),
          ),
        ],
      )),
    );
  }
}

// ── Bar chart ────────────────────────────────────────────
class _BarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final Color color, gridColor, text3;
  final bool isDark;

  const _BarChart({required this.data, required this.labels, required this.color, required this.gridColor, required this.text3, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox(height: 150);
    final show = data.length > 14 ? data.sublist(data.length - 14) : data;
    final showL = labels.length > 14 ? labels.sublist(labels.length - 14) : labels;

    return SizedBox(
      height: 160,
      child: BarChart(BarChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 0.5)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= showL.length) return const SizedBox();
              return Text(showL[i], style: TextStyle(fontSize: 8, color: text3));
            },
          )),
        ),
        borderData: FlBorderData(show: false),
        barGroups: show.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
          BarChartRodData(toY: e.value, color: color.withOpacity(0.8), width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
        ])).toList(),
      )),
    );
  }
}

// ── Heatmap ──────────────────────────────────────────────
class _HeatmapWidget extends StatelessWidget {
  final List<DayHistory> pts;
  final Color surface2, text3;
  const _HeatmapWidget({required this.pts, required this.surface2, required this.text3});

  Color _heatColor(int pct) {
    if (pct >= 80) return const Color(0xFF16A34A);
    if (pct >= 60) return const Color(0xFF4ADE80);
    if (pct >= 40) return const Color(0xFFFCD34D);
    if (pct >= 20) return const Color(0xFFF87171);
    return surface2;
  }

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final show = pts.length > 49 ? pts.sublist(pts.length - 49) : pts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: dayLabels.map((d) => Expanded(child: Center(child: Text(d, style: TextStyle(fontSize: 9, color: text3))))).toList()),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 3, crossAxisSpacing: 3),
          itemCount: show.length,
          itemBuilder: (_, i) => Tooltip(
            message: '${show[i].date.month}/${show[i].date.day}: ${show[i].habitPct}%',
            child: Container(decoration: BoxDecoration(color: _heatColor(show[i].habitPct), borderRadius: BorderRadius.circular(3))),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('less ', style: TextStyle(fontSize: 9, color: text3)),
            ...[surface2, const Color(0xFFFCD34D), const Color(0xFF4ADE80), const Color(0xFF16A34A)].map((c) => Container(
              width: 9, height: 9, margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
            )),
            Text(' more', style: TextStyle(fontSize: 9, color: text3)),
          ],
        ),
      ],
    );
  }
}

// ── Helper cards ─────────────────────────────────────────
// ── Empty chart placeholder ──────────────────────────────
class _EmptyChart extends StatelessWidget {
  final String msg;
  final Color text3;
  const _EmptyChart(this.msg, this.text3);
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 80,
    child: Center(child: Text(msg, style: TextStyle(fontSize: 12, color: text3), textAlign: TextAlign.center)),
  );
}

class _ChartCard extends StatelessWidget {
  final String title, sub;
  final IconData icon;
  final Color titleColor, surface, border, text, text3;
  final Widget child;

  const _ChartCard({required this.title, required this.sub, required this.icon, required this.titleColor,
      required this.surface, required this.border, required this.text, required this.text3, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [Icon(icon, size: 14, color: titleColor), const SizedBox(width: 6), Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: titleColor))]),
        Text(sub, style: TextStyle(fontSize: 10, color: text3, fontFamily: 'monospace')),
      ]),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconBg, iconColor, surface, border, text, text3;
  final bool isDark;

  const _StatCard({required this.label, required this.value, required this.icon, required this.iconBg,
      required this.iconColor, required this.surface, required this.border, required this.text, required this.text3, required this.isDark});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 26, height: 26, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(7)), child: Icon(icon, size: 14, color: iconColor)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: text, fontFamily: 'monospace')),
        Text(label, style: TextStyle(fontSize: 9, color: text3)),
      ]),
    ),
  );
}

class _DateBanner extends StatelessWidget {
  final DateTime date;
  final bool isDark;
  final Color surface, border, text2;

  const _DateBanner({required this.date, required this.isDark, required this.surface, required this.border, required this.text2});

  @override
  Widget build(BuildContext context) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const wdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(9), border: Border.all(color: border, width: 0.5)),
      child: Text('Viewing: ${wdays[date.weekday-1]}, ${months[date.month-1]} ${date.day}, ${date.year}',
          style: TextStyle(fontSize: 12, color: text2, fontFamily: 'monospace')),
    );
  }
}
