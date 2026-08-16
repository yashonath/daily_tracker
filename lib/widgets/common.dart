import 'package:flutter/material.dart';

// ── App scaffold with logo header ──────────────────────
class TrackerScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? fab;

  const TrackerScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF111110) : const Color(0xFFFAFAF9);
    final text    = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final text3   = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    final border  = isDark ? const Color(0x12FFFFFF) : const Color(0x12000000);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: fab,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: bg,
                border: Border(bottom: BorderSide(color: border, width: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 28,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    subtitle ?? _fmtDate(),
                    style: TextStyle(
                      fontSize: 11,
                      color: text3,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  String _fmtDate() {
    final d = DateTime.now();
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }
}

// ── Section label ───────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final text3 = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF4A4A46)
        : const Color(0xFFB0AFA8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: text3,
        ),
      ),
    );
  }
}

// ── Tracker card ────────────────────────────────────────
class TrackerCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const TrackerCard({super.key, required this.child, this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1A19) : Colors.white;
    final border  = isDark ? const Color(0x14FFFFFF) : const Color(0x14000000);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 0.5),
        ),
        child: child,
      ),
    );
  }
}

// ── Check button ────────────────────────────────────────
class CheckButton extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;

  const CheckButton({super.key, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text   = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final bgCol  = isDark ? const Color(0xFF111110) : Colors.white;
    final border = isDark ? const Color(0x33FFFFFF) : const Color(0x33000000);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22, height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? text : Colors.transparent,
          border: Border.all(
            color: checked ? text : border,
            width: 1.5,
          ),
        ),
        child: checked
            ? Icon(Icons.check_rounded, size: 13, color: bgCol)
            : null,
      ),
    );
  }
}

// ── Priority badge ──────────────────────────────────────
class PriorityBadge extends StatelessWidget {
  final String priority;
  const PriorityBadge(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bg; Color fg; String label;
    switch (priority) {
      case 'high':
        bg = const Color(0xFFFEF2F2); fg = const Color(0xFFDC2626); label = 'High'; break;
      case 'low':
        bg = const Color(0xFFF0FDF4); fg = const Color(0xFF16A34A); label = 'Low';  break;
      default:
        bg = const Color(0xFFFFFBEB); fg = const Color(0xFFD97706); label = 'Med';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Pill group selector ─────────────────────────────────
class PillGroup extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  const PillGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final surface  = isDark ? const Color(0xFF1A1A19) : Colors.white;
    final surface2 = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);
    final text     = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final text3    = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final active = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: active ? surface : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: active
                    ? [BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      )]
                    : null,
              ),
              child: Text(
                options[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                  color: active ? text : text3,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Progress bar ────────────────────────────────────────
class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const ProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final track  = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);

    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        backgroundColor: track,
        valueColor: AlwaysStoppedAnimation(color),
        minHeight: height,
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Color(0xFFB0AFA8)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Info row ────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8),
              fontFamily: 'monospace',
            )),
        Text(value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110),
              fontFamily: 'monospace',
            )),
      ],
    );
  }
}
