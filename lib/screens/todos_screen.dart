import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});
  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final _ctrl = TextEditingController();
  TaskPriority _priority = TaskPriority.med;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _add(AppProvider p) {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    p.addTodo(v, _priority);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TrackerScaffold(
      title: 'daily.track',
      body: Consumer<AppProvider>(
        builder: (ctx, p, _) {
          final sorted = [...p.todos]..sort((a, b) {
            const o = {'high': 0, 'med': 1, 'low': 2};
            final po = (o[a.priority.name] ?? 1).compareTo(o[b.priority.name] ?? 1);
            if (po != 0) return po;
            return a.done ? 1 : -1;
          });

          return Column(
            children: [
              SectionLabel('Tasks'),
              Expanded(
                child: sorted.isEmpty
                    ? const EmptyState('No tasks yet.\nAdd one below!')
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: sorted.length,
                        itemBuilder: (_, i) => _TodoCard(todo: sorted[i], provider: p, isDark: isDark),
                      ),
              ),
              // Add row
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111110) : const Color(0xFFFAFAF9),
                  border: Border(top: BorderSide(color: isDark ? const Color(0x12FFFFFF) : const Color(0x12000000), width: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            decoration: const InputDecoration(hintText: 'New task…', hintStyle: TextStyle(color: Color(0xFFB0AFA8))),
                            onSubmitted: (_) => _add(p),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _AddButton(onTap: () => _add(p), isDark: isDark),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Priority:', style: TextStyle(fontSize: 12, color: Color(0xFFB0AFA8))),
                        const SizedBox(width: 8),
                        ...TaskPriority.values.map((pr) => GestureDetector(
                          onTap: () => setState(() => _priority = pr),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _priority == pr ? _priorityColor(pr) : Colors.transparent,
                              border: Border.all(color: _priorityColor(pr).withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(pr.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _priority == pr ? Colors.white : _priorityColor(pr))),
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case TaskPriority.high: return const Color(0xFFDC2626);
      case TaskPriority.low: return const Color(0xFF16A34A);
      default: return const Color(0xFFD97706);
    }
  }
}

class _TodoCard extends StatelessWidget {
  final Todo todo;
  final AppProvider provider;
  final bool isDark;
  const _TodoCard({required this.todo, required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
      ),
      onDismissed: (_) => provider.deleteTodo(todo.id),
      child: TrackerCard(
        child: Row(
          children: [
            CheckButton(checked: todo.done, onTap: () => provider.toggleTodo(todo.id)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(todo.label,
                  style: TextStyle(fontSize: 14, color: todo.done ? text.withOpacity(0.3) : text,
                      decoration: todo.done ? TextDecoration.lineThrough : null)),
            ),
            const SizedBox(width: 8),
            PriorityBadge(todo.priority.name),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;
  const _AddButton({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final text = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final bg = isDark ? const Color(0xFF111110) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: text, borderRadius: BorderRadius.circular(9)),
        child: Row(
          children: [Icon(Icons.add_rounded, size: 16, color: bg), const SizedBox(width: 4), Text('Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: bg))],
        ),
      ),
    );
  }
}
