import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _selectedMood = '😌';
  final _moods = ['😌', '😊', '😔', '⚡', '🙏'];
  final _moodLabels = ['Calm', 'Good', 'Low', 'Wired', 'Grateful'];

  @override
  void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }

  void _save(AppProvider p) {
    final t = _titleCtrl.text.trim();
    final b = _bodyCtrl.text.trim();
    if (t.isEmpty && b.isEmpty) return;
    p.addJournalEntry(t.isEmpty ? 'Untitled' : t, b, _selectedMood);
    _titleCtrl.clear(); _bodyCtrl.clear();
    FocusScope.of(context).unfocus();
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
        builder: (ctx, p, _) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Journal'.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: text3)),
                  Text('${p.journal.length} ${p.journal.length == 1 ? "entry" : "entries"}', style: TextStyle(fontSize: 11, color: text3, fontFamily: 'monospace')),
                ],
              ),
            ),

            // Entries
            ...p.journal.map((e) => _EntryCard(entry: e, provider: p, isDark: isDark, surface: surface, surface2: surface2, text: text, text2: text2, text3: text3, border: border)),

            if (p.journal.isEmpty) const EmptyState('No entries yet.\nWrite your first one below.'),

            // Compose area
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 0.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text),
                    decoration: InputDecoration.collapsed(hintText: 'Title your entry…', hintStyle: TextStyle(color: text3, fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 10),
                  // Mood chips
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _moods.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final active = _selectedMood == _moods[i];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMood = _moods[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: active ? text : Colors.transparent,
                              border: Border.all(color: active ? text : (isDark ? const Color(0x22FFFFFF) : const Color(0x22000000))),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text('${_moods[i]} ${_moodLabels[i]}', style: TextStyle(fontSize: 12, color: active ? (isDark ? const Color(0xFF111110) : Colors.white) : text3)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: 4, minLines: 3,
                    style: TextStyle(fontSize: 13, color: text2, height: 1.6),
                    decoration: InputDecoration.collapsed(hintText: 'Write your thoughts for today…', hintStyle: TextStyle(color: text3, fontSize: 13)),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: border, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () { _titleCtrl.clear(); _bodyCtrl.clear(); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: border)),
                          child: Text('Clear', style: TextStyle(fontSize: 12, color: text2)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _save(p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(color: text, borderRadius: BorderRadius.circular(6)),
                          child: Text('Save entry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF111110) : Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatefulWidget {
  final JournalEntry entry;
  final AppProvider provider;
  final bool isDark;
  final Color surface, surface2, text, text2, text3, border;

  const _EntryCard({required this.entry, required this.provider, required this.isDark,
      required this.surface, required this.surface2, required this.text, required this.text2, required this.text3, required this.border});

  @override
  State<_EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<_EntryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${months[e.date.month - 1]} ${e.date.day}';

    return Dismissible(
      key: Key(e.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
      ),
      onDismissed: (_) => widget.provider.deleteJournalEntry(e.id),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: widget.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: widget.border, width: 0.5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(e.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: widget.text), overflow: TextOverflow.ellipsis)),
                  Text(e.mood, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: widget.surface2, borderRadius: BorderRadius.circular(4)),
                    child: Text(dateStr, style: TextStyle(fontSize: 10, color: widget.text3, fontFamily: 'monospace')),
                  ),
                ],
              ),
              if (!_expanded && e.body.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(e.body, style: TextStyle(fontSize: 12, color: widget.text3), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
              if (_expanded && e.body.isNotEmpty) ...[
                Divider(color: widget.border, height: 20),
                Text(e.body, style: TextStyle(fontSize: 13, color: widget.text2, height: 1.65)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
