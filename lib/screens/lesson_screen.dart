import 'package:flutter/material.dart';
import '../data/models/lesson.dart';
import '../data/models/task.dart';
import '../data/services/storage_service.dart';
import '../data/services/lesson_data_provider.dart';
import '../data/services/gamification_service.dart';
import '../data/services/sound_service.dart';
import '../widgets/task_widget.dart';
import '../widgets/premium_animations.dart';

class LessonScreen extends StatefulWidget {
  final int lessonId;
  final String userName;
  final VoidCallback? onComplete;
  const LessonScreen({super.key, required this.lessonId, required this.userName, this.onComplete});
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late Lesson? _lesson;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _lesson = LessonDataProvider.getLessonById(widget.lessonId);
  }

  Future<void> _completeLesson() async {
    if (_isCompleting) return;
    SoundService().playComplete();
    setState(() => _isCompleting = true);
    await StorageService.addCompletedLesson(widget.lessonId);
    await GamificationService.addLessonComplete();
    if (mounted) {
      widget.onComplete?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lesson == null) return const Scaffold(body: Center(child: Text('Урок не найден')));
    const lessonColor = Color(0xFF6C63FF);

    return Scaffold(
      appBar: AppBar(
        title: Text('Миссия ${_lesson!.order}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Теория (Компактно)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: lessonColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Icon(Icons.rocket_launch, color: lessonColor, size: 32),
                  const SizedBox(height: 10),
                  Text(_lesson!.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(_lesson!.theoryText, style: const TextStyle(fontSize: 14, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Практика (Сразу под теорией)
            const Text('ТВОЕ ЗАДАНИЕ:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            ..._lesson!.tasks.map((task) => TaskWidget(task: task)).toList(),
            const SizedBox(height: 30),
            // Кнопка Завершить
            PremiumButton(
              text: 'ЗАВЕРШИТЬ МИССИЮ',
              onPressed: _completeLesson,
              icon: Icons.done_all,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
