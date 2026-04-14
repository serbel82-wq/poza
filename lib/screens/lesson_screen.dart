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
  final Set<String> _completedTaskIds = {};

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
  
  // --- Новая логика геймификации ---

  void _handleTaskAnswered(Task task) {
    // Используем ID задачи или ее заголовок как уникальный идентификатор
    final taskId = (task.id?.isNotEmpty ?? false) ? task.id! : task.title;
    if (_completedTaskIds.contains(taskId)) {
      return; // Награда за это задание уже выдана
    }

    setState(() {
      _completedTaskIds.add(taskId);
    });

    final xp = task.totalPoints;
    // TODO: Добавить в GamificationService метод для сохранения XP за задание, например:
    // GamificationService.addTaskXp(xp);
    
    _showXpToast(xp);
  }

  void _showXpToast(int xp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            XpBadge(xp: xp, showPlus: true),
            const SizedBox(width: 8),
            const Text('Отлично!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.fromLTRB(15, 5, 15, 30),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // --- Конец новой логики ---

  void _nextPage() {
    if (_currentPage < 2) {
      SoundService().playClick();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      SoundService().playClick();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeLesson() async {
    if (_isCompleting) return;

    SoundService().playComplete();
    setState(() => _isCompleting = true);

    await StorageService.addCompletedLesson(widget.lessonId);

    // Gamification - add XP for lesson completion
    final xpEarned = await GamificationService.addLessonComplete();

    // Calculate score based on completed tasks (for stars)
    final lesson = _lesson;
    int taskScore = 50; // Default score
    if (lesson != null && lesson.tasks.isNotEmpty) {
      final completedTasks = _completedTaskIds.length;
      final totalTasks = lesson.tasks.length;
      taskScore = totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 50;
    }

    // Add stars based on score
    final starsEarned = await GamificationService.addLessonWithStars(
      lesson?.seasonId ?? 1,
      taskScore,
    );

    // Check for achievements
    if (widget.lessonId == 1) {
      await GamificationService.unlockAchievement('first_step');
    }

    if (mounted) {
      widget.onComplete?.call();
      _showCompletionDialog(xpEarned, starsEarned);
    }
  }

  void _showCompletionDialog(int xpEarned, int starsEarned) {
    final nextLesson = LessonDataProvider.getNextLesson(widget.lessonId);
    final stats = GamificationService.getGamificationStats();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 32),
            const SizedBox(width: 12),
            const Text('Урок пройден!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: List.generate(3, (index) => Icon(
                      Icons.star,
                      color: index < starsEarned ? Colors.amber : Colors.grey.shade300,
                      size: 28,
                    )),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+$xpEarned XP',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  GamificationService.getLevelEmoji(stats['level'] as int),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  'Уровень ${stats['level']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if ((stats['currentStreak'] as int) > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text('Серия: ${stats['currentStreak']} дней'),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text('Отлично, ${widget.userName}! Ты молодец!'),
            const SizedBox(height: 16),
            if (nextLesson != null)
              Text('Следующий урок: "${nextLesson.title}"')
            else
              const Text('Ты завершил первый сезон!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (nextLesson != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => LessonScreen(
                      lessonId: nextLesson.id,
                      userName: widget.userName,
                      onComplete: widget.onComplete,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
                nextLesson != null ? 'К следующему уроку' : 'Назад к урокам'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Урок')),
        body: const Center(child: Text('Урок не найден')),
      );
    }

    final pages = [
      _buildTheoryPage(),
      _buildTasksPage(),
      _buildCompletionPage(),
    ];

    final lessonColors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];
    final lessonColor = lessonColors[(_lesson!.id - 1) % lessonColors.length];

    return Scaffold(
      appBar: AppBar(
        title: Text('Урок ${_lesson!.order}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedGradientBackground(
        colors: [
          lessonColor.withOpacity(0.1),
          Colors.white,
          Colors.white,
        ],
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentPage == 0 ? 'Изучаем' : (_currentPage == 1 ? 'Практика' : 'Финиш'),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: lessonColor,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_currentPage + 1} / 3',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: lessonColor.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / 3,
                        minHeight: 8,
                        backgroundColor: lessonColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(lessonColor),
                      ),
                    ),
                  ],
                ),
              ),
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
    final lessonColors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];
    final lessonColor = lessonColors[(_lesson!.id - 1) % lessonColors.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FloatingWidget(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [lessonColor, lessonColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: lessonColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _getLessonIcon(_lesson!.id),
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _lesson!.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'ЭТО ИНТЕРЕСНО',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  fontSize: 14,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            backgroundColor: Colors.white,
            borderRadius: 24,
            padding: const EdgeInsets.all(20),
            child: Text(
              _lesson!.theoryText,
              style: const TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Color(0xFF2D3436),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lessonColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lessonColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: lessonColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Чтение займет около ${_lesson!.durationMinutes} минут',
                  style: TextStyle(
                    color: lessonColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksPage() {
    final lessonColors = [
      Colors.blue, Colors.purple, Colors.orange, Colors.teal,
      Colors.red, Colors.green, Colors.indigo, Colors.pink,
    ];
    final lessonColor = lessonColors[(_lesson!.id - 1) % lessonColors.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ..._lesson!.tasks.map((task) => TaskWidget(
            task: task,
            onAnswered: (answers) => _handleTaskAnswered(task),
          )).toList(),
        ],
      ),
    );
  }

  IconData _getLessonIcon(int id) {
    final icons = [Icons.school, Icons.psychology, Icons.edit_note, Icons.image, Icons.fact_check, Icons.security, Icons.menu_book, Icons.smart_toy];
    return icons[(id - 1) % icons.length];
  }

  Widget _buildCompletionPage() {
    final lessonColors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];
    final lessonColor = lessonColors[(_lesson!.id - 1) % lessonColors.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              const PulseAnimation(
                child: GlowEffect(
                  color: Colors.green,
                  blurRadius: 50,
                  child: SizedBox(width: 150, height: 150),
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Ура! Ты это сделал!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ты только что стал еще на шаг ближе к званию Мастера Нейросетей!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
          GlassCard(
            borderRadius: 24,
            backgroundColor: Colors.amber.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 32),
                const SizedBox(width: 12),
                Text(
                  '+50 XP ЖДЕТ ТЕБЯ!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: PremiumButton(
              onPressed: _isCompleting ? null : _completeLesson,
              text: _isCompleting ? 'СОХРАНЯЕМ...' : 'ЗАВЕРШИТЬ УРОК!',
              icon: Icons.celebration,
              gradientStart: Colors.green,
              gradientEnd: Colors.teal,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Выйти без сохранения',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(Color lessonColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentPage > 0)
              IconButton.filledTonal(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              )
            else
              const SizedBox(width: 56),
            const Spacer(),
            if (_currentPage < 2)
              SizedBox(
                height: 56,
                child: PremiumButton(
                  onPressed: _nextPage,
                  text: _currentPage == 1 ? 'ФИНИШ!' : 'К ЗАДАНИЯМ',
                  icon: Icons.arrow_forward,
                  gradientStart: lessonColor,
                  gradientEnd: lessonColor.withOpacity(0.7),
                ),
              )
            else
              const SizedBox(width: 56),
          ],
        ),
      ),
    );
  }

}
