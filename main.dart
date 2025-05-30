import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  runApp(const ChecklistApp());
}

class ChecklistApp extends StatelessWidget {
  const ChecklistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEO CHECK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF073A),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Color(0xFFFF073A),
                blurRadius: 10,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
      home: const ChecklistPage(),
    );
  }
}

class Task {
  final String id;
  String title;
  bool isDone;
  DateTime createdAt;
  DateTime? completedAt;
  int priority;

  Task({
    required this.title,
    this.isDone = false,
    this.priority = 2,
    DateTime? createdAt,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(100).toString(),
        createdAt = createdAt ?? DateTime.now();

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

class _ChecklistPageState extends State<ChecklistPage>
    with SingleTickerProviderStateMixin {
  final List<Task> _tasks = [];
  late AnimationController _animationController;
  final _scrollController = ScrollController();
  int _sortOption = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _loadDemoTasks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDemoTasks() {
    setState(() {
      _tasks.addAll([
        Task(title: 'Купить продукты', priority: 1),
        Task(title: 'Подготовить отчет', priority: 3),
        Task(title: 'Записаться к врачу', priority: 2),
        Task(title: 'Прочитать книгу', priority: 2),
        Task(title: 'Сделать зарядку', priority: 1),
        Task(title: 'Заплатить за интернет', priority: 3),
        Task(title: 'Позвонить родителям', priority: 3),
      ]);
    });
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => GlassTaskDialog(
        title: 'Новая задача',
        hint: 'Что нужно сделать?',
        onConfirm: (text, priority) => _addTask(text, priority),
      ),
    );
  }

  void _addTask(String text, int priority) {
    setState(() {
      _tasks.insert(0, Task(title: text, priority: priority));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });

    _showSnackbar('Задача добавлена');
  }

  void _editTask(Task task) {
    final controller = TextEditingController(text: task.title);
    showDialog(
      context: context,
      builder: (_) => GlassTaskDialog(
        title: 'Редактировать',
        initialText: controller.text,
        initialPriority: task.priority,
        onConfirm: (text, priority) {
          setState(() {
            task.title = text;
            task.priority = priority;
          });
          _showSnackbar('Задача обновлена');
        },
      ),
    );
  }

  void _toggleDone(Task task) {
    setState(() {
      task.toggleDone();
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
    _showSnackbar('Задача удалена');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _sortTasks() {
    setState(() {
      if (_sortOption == 0) {
        _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _tasks.sort((a, b) => b.priority.compareTo(a.priority));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _tasks.length;
    final completedCount = _tasks.where((t) => t.isDone).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'NEO CHECK',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Color(0xFFFF073A),
                blurRadius: 15,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: GlassBackground(
          intensity: 0.05,
          blur: 10,
        ),
        actions: [
          IconButton(
            icon: Icon(_sortOption == 0 ? Icons.access_time : Icons.priority_high),
            onPressed: () {
              setState(() => _sortOption = _sortOption == 0 ? 1 : 0);
              _sortTasks();
            },
            tooltip: 'Сортировка',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF0A0005),
              Color(0xFF1A0010),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ParticleField(particleCount: 50),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: _tasks.isEmpty
                  ? const EmptyPlaceholder()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 16, bottom: 120),
                      itemCount: _tasks.length,
                      itemBuilder: (ctx, i) => _buildTaskItem(_tasks[i]),
                    ),
            ),
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ЗАДАЧИ: $totalCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      'ВЫПОЛНЕНО: $completedCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF073A).withOpacity(0.9),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFFF073A),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFFF073A),
            width: 2,
          ),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF073A),
            width: 2,
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Color(0xFFFF073A),
          size: 32,
        ),
      ),
      onDismissed: (direction) => _deleteTask(task),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _toggleDone(task),
            onLongPress: () => _editTask(task),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: AnimatedCheckbox(value: task.isDone),
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isDone
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.9),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.completedAt != null)
                      Text(
                        'Выполнено: ${_formatDate(task.completedAt!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFFFF073A).withOpacity(0.8),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(3, (index) {
                        return Icon(
                          Icons.circle,
                          size: 10,
                          color: index < task.priority
                              ? const Color(0xFFFF073A)
                              : Colors.grey.withOpacity(0.3),
                        );
                      }),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, 
                      color: Colors.white.withOpacity(0.6)),
                  onPressed: () => _editTask(task),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassTaskDialog extends StatelessWidget {
  final String title;
  final String hint;
  final String? initialText;
  final int? initialPriority;
  final void Function(String, int) onConfirm;

  const GlassTaskDialog({
    super.key,
    required this.title,
    this.hint = '',
    this.initialText,
    this.initialPriority = 2,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialText);
    int priority = initialPriority ?? 2;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: GlassCard(
        blur: 15,
        intensity: 0.2,
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.9),
                  shadows: const [
                    Shadow(
                      color: Color(0xFFFF073A),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Text(
                'Приоритет:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [1, 2, 3].map((p) {
                  return ChoiceChip(
                    label: Text('$p', style: TextStyle(
                      color: priority == p ? Colors.black : Colors.white
                    )),
                    selected: priority == p,
                    onSelected: (selected) {
                      priority = p;
                    },
                    selectedColor: const Color(0xFFFF073A),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Отмена',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        onConfirm(text, priority);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF073A),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      shadowColor: const Color(0xFFFF073A).withOpacity(0.5),
                      elevation: 8,
                    ),
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double intensity;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    this.intensity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(intensity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: const Color(0xFFFF073A).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF073A).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassBackground extends StatelessWidget {
  final double blur;
  final double intensity;
  final Widget? child;

  const GlassBackground({
    super.key,
    this.blur = 5,
    this.intensity = 0.1,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(intensity),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFFF073A).withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AnimatedCheckbox extends StatelessWidget {
  final bool value;

  const AnimatedCheckbox({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFFFF073A)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value
              ? const Color(0xFFFF073A)
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: value
            ? [
                BoxShadow(
                  color: const Color(0xFFFF073A).withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: value
          ? const Icon(Icons.check, color: Colors.black, size: 20)
          : null,
    );
  }
}

class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 100,
            color: const Color(0xFFFF073A).withOpacity(0.2),
          ),
          const SizedBox(height: 24),
          Text(
            'СПИСОК ПУСТ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFF073A).withOpacity(0.4),
              letterSpacing: 1.5,
              shadows: const [
                Shadow(
                  color: Color(0xFFFF073A),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте свою первую задачу',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticleField extends StatelessWidget {
  final int particleCount;

  const ParticleField({super.key, this.particleCount = 20});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: ParticlePainter(particleCount: particleCount),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final int particleCount;
  final Random random = Random();

  ParticlePainter({required this.particleCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF073A).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 4 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final linePaint = Paint()
      ..color = const Color(0xFFFF073A).withOpacity(0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < particleCount ~/ 2; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final endX = startX + random.nextDouble() * 100 - 50;
      final endY = startY + random.nextDouble() * 100 - 50;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}