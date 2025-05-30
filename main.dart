import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ChecklistApp());
}

class ChecklistApp extends StatelessWidget {
  const ChecklistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Премиум Чек-лист',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006A71)),
        fontFamily: 'Rubik',
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: const ChecklistPage(),
    );
  }
}

class Task {
  String title;
  bool isDone;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.title,
    this.isDone = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  void toggleDone() {
    isDone = !isDone;
    completedAt = isDone ? DateTime.now() : null;
  }
}

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final List<Task> _tasks = [];
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadDemoTasks();
  }

  void _loadDemoTasks() {
    _tasks.addAll([
      Task(title: 'Купить продукты'),
      Task(title: 'Подготовить отчет', isDone: true),
      Task(title: 'Записаться к врачу'),
      Task(title: 'Прочитать книгу'),
      Task(title: 'Сделать зарядку', isDone: true),
    ]);
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => _TaskDialog(
        title: 'Новая задача',
        hint: 'Что нужно сделать?',
        onConfirm: (text) => _addTask(text),
      ),
    );
  }

  void _addTask(String text) {
    setState(() {
      _tasks.insert(0, Task(title: text));
    });
    _showSnackbar('Задача добавлена');
  }

  void _editTask(int index) {
    final controller = TextEditingController(text: _tasks[index].title);
    showDialog(
      context: context,
      builder: (_) => _TaskDialog(
        title: 'Редактировать задачу',
        initialText: controller.text,
        onConfirm: (text) {
          setState(() => _tasks[index].title = text);
          _showSnackbar('Задача обновлена');
        },
      ),
    );
  }

  void _toggleDone(int index) {
    setState(() {
      _tasks[index].toggleDone();
    });
  }

  void _removeTask(int index) {
    final removed = _tasks.removeAt(index);
    _showActionSnackbar(
      'Удалена: "${removed.title}"',
      actionLabel: 'Отменить',
      onAction: () => setState(() => _tasks.insert(index, removed)),
    );
  }

  void _clearCompleted() {
    setState(() => _tasks.removeWhere((t) => t.isDone));
    _showSnackbar('Выполненные задачи очищены');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showActionSnackbar(String message,
      {required String actionLabel, required VoidCallback onAction}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: actionLabel,
          onPressed: onAction,
          textColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.where((t) => t.isDone);
    final active = _tasks.where((t) => !t.isDone);
    final visible = [...active, if (_showCompleted) ...completed];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой Чек-лист'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showCompleted ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () => setState(() => _showCompleted = !_showCompleted),
          ),
          if (completed.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cleaning_services),
              onPressed: _clearCompleted,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
              Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: visible.isEmpty
            ? _EmptyPlaceholder()
            : ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 100),
                itemCount: visible.length,
                itemBuilder: (ctx, i) {
                  final task = visible[i];
                  final originalIndex = _tasks.indexOf(task);
                  return Dismissible(
                    key: ValueKey(task),
                    direction: DismissDirection.endToStart,
                    background: _deleteBackground(),
                    confirmDismiss: (_) => _confirmDelete(task.title),
                    onDismissed: (_) => _removeTask(originalIndex),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Card(
                        key: ValueKey(task.isDone),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _toggleDone(originalIndex),
                          onLongPress: () => _editTask(originalIndex),
                          child: ListTile(
                            leading: _AnimatedCheckbox(value: task.isDone),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.isDone
                                    ? Theme.of(context).disabledColor
                                    : null,
                              ),
                            ),
                            subtitle: task.completedAt != null
                                ? Text(
                                    'Выполнено: ${_formatDate(task.completedAt!)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                  )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editTask(originalIndex),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _deleteBackground() => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        child: const Icon(Icons.delete, color: Colors.red),
      );

  Future<bool?> _confirmDelete(String title) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: Text('"$title"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Удалить')),
        ],
      ),
    );
  }
}

class _TaskDialog extends StatelessWidget {
  final String title;
  final String hint;
  final String? initialText;
  final void Function(String) onConfirm;

  const _TaskDialog({
    super.key,
    required this.title,
    this.hint = '',
    this.initialText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialText);
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      onConfirm(text);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_rtl,
            size: 100,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Ваш список задач пуст',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите + чтобы добавить задачу',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AnimatedCheckbox extends StatelessWidget {
  final bool value;

  const _AnimatedCheckbox({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: value ? Theme.of(context).colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: 2,
        ),
      ),
      child: value
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : null,
    );
  }
}
