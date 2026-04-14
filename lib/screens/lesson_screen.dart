import 'package:flutter/material.dart';
import '../data/models/lesson.dart';
import '../data/models/task.dart';
import '../data/services/storage_service.dart';
import '../data/services/lesson_data_provider.dart';
import '../data/services/gamification_service.dart';
import '../data/services/sound_service.dart';
import '../widgets/task_widget.dart';
import '../widgets/gamification_widgets.dart';
import '../widgets/premium_animations.dart';
import '../app_routes.dart';

class LessonScreen extends StatefulWidget {
  final int lessonId;
  final String userName;
  final VoidCallback? onComplete;

  const LessonScreen({
    super.key,
    required this.lessonId,
    required this.userName,
    this.onComplete,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late Lesson? _lesson;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _lesson = LessonDataProvider.getLessonById(widget.lessonId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      SoundService().playClick();
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      SoundService().playClick();
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
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

    final pages = [_buildTheoryPage(), _buildTasksPage(), _buildCompletionPage()];
    const lessonColor = Color(0xFF6C63FF);

    return Scaffold(
      appBar: AppBar(title: Text('Миссия ${_lesson!.order}'), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: AnimatedGradientBackground(
        colors: [lessonColor.withOpacity(0.1), Colors.white],
        child: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(value: (_currentPage + 1) / 3, minHeight: 8),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: pages.length,
                  itemBuilder: (context, index) => pages[index],
                ),
              ),
              _buildNavigationBar(lessonColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTheoryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          FloatingWidget(
            child: GlassCard(
              backgroundColor: const Color(0xFF6C63FF),
              child: Column(
                children: [
                  const Icon(Icons.rocket_launch, color: Colors.white, size: 50),
                  const SizedBox(height: 16),
                  Text(_lesson!.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            backgroundColor: Colors.white,
            child: Text(_lesson!.theoryText, style: const TextStyle(fontSize: 16, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: _lesson!.tasks.map((task) => TaskWidget(task: task)).toList(),
      ),
    );
  }

  Widget _buildCompletionPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const PulseAnimation(child: Icon(Icons.emoji_events, size: 100, color: Colors.amber)),
        const SizedBox(height: 24),
        const Text('Миссия выполнена!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Ты отлично справился, Исследователь!', textAlign: TextAlign.center),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: PremiumButton(
            text: 'ЗАВЕРШИТЬ',
            onPressed: _completeLesson,
            icon: Icons.check,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar(Color color) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0) IconButton(onPressed: _previousPage, icon: const Icon(Icons.arrow_back)) else const SizedBox(width: 48),
          if (_currentPage < 2) PremiumButton(text: 'ДАЛЕЕ', onPressed: _nextPage, icon: Icons.arrow_forward) else const SizedBox(width: 48),
        ],
      ),
    );
  }
}
