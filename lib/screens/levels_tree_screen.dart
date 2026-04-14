import 'package:flutter/material.dart';
import 'lesson_screen.dart';
import 'final_project_screen.dart';
import 'avatar_selection_screen.dart';
import 'parent_dashboard_screen.dart';
import 'chat_screen.dart';
import 'subscription_screen.dart';
import 'ai_chat_screen.dart';
import '../data/models/season.dart';
import '../data/models/lesson.dart';
import '../data/services/storage_service.dart';
import '../data/services/lesson_data_provider.dart';
import '../data/services/gamification_service.dart';
import '../data/services/firebase_service.dart';
import '../data/services/sound_service.dart';
import '../widgets/gamification_widgets.dart';
import '../widgets/premium_animations.dart';
import '../app_routes.dart';

class LevelsTreeScreen extends StatefulWidget {
  const LevelsTreeScreen({
    super.key,
    this.userName = '',
    this.initialLessonId,
  });

  final String userName;
  final int? initialLessonId;

  @override
  State<LevelsTreeScreen> createState() => _LevelsTreeScreenState();
}

class _LevelsTreeScreenState extends State<LevelsTreeScreen> {
  late String _displayName;
  List<Season> _seasons = [];
  List<Lesson> _currentSeasonLessons = [];
  int _selectedSeason = 1;
  int? _expandedSeasonId;

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName.isNotEmpty
        ? widget.userName
        : (StorageService.getUserName() ?? 'Путник');
    _loadData();
    _processDailyLogin();

    if (widget.initialLessonId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openLesson(widget.initialLessonId!);
      });
    }
  }

  void _processDailyLogin() async {
    final xpEarned = await GamificationService.processDailyLogin();
    if (xpEarned > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Text('+$xpEarned XP за ежедневный вход!'),
            ],
          ),
          backgroundColor: Colors.deepPurple,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _loadData() {
    final subscriptionInfo = SubscriptionService().getSubscriptionInfo();
    final isSubscribed = subscriptionInfo['isSubscribed'] as bool? ?? false;
    final isTrialActive = subscriptionInfo['isTrialActive'] as bool? ?? true;
    
    final freeSeasonLimit = (isSubscribed || isTrialActive) ? 8 : 1;
    
    setState(() {
      _seasons = LessonDataProvider.getSeasons();
      _currentSeasonLessons = LessonDataProvider.getLessonsBySeason(_selectedSeason);

      _seasons = _seasons.map((season) {
        final seasonLessons = LessonDataProvider.getLessonsBySeason(season.id);
        final completedCount = seasonLessons
            .where((l) => StorageService.isLessonCompleted(l.id))
            .length;
        final totalLessons = seasonLessons.length;
        final progress = totalLessons > 0 ? completedCount / totalLessons : 0.0;

        bool isUnlocked = season.id <= freeSeasonLimit;
        if (season.id > 1) {
          final prevSeasonIndex = season.id - 2;
          if (prevSeasonIndex < _seasons.length) {
            final prevSeason = _seasons[prevSeasonIndex];
            isUnlocked = prevSeason.progress >= 1.0 && season.id <= freeSeasonLimit;
          }
        }

        return season.copyWith(
          progress: progress,
          isUnlocked: isUnlocked,
        );
      }).toList();
    });
  }

  void _openLesson(int lessonId) {
    SoundService().playClick();
    final lessonSeason = LessonDataProvider.getSeasons().firstWhere(
      (s) => LessonDataProvider.getLessonsBySeason(s.id).any((l) => l.id == lessonId),
      orElse: () => LessonDataProvider.getSeasons().first,
    );
    
    final seasonUnlockStatus = _seasons.firstWhere(
      (s) => s.id == lessonSeason.id,
      orElse: () => _seasons.first,
    );
    
    if (!seasonUnlockStatus.isUnlocked) {
      final requiredSeason = lessonSeason.id == 2 ? 'Сезон 1' : 'Сезон ${lessonSeason.id - 1}';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Сезон закрыт'),
          content: Text(
            'Чтобы открыть ${lessonSeason.title}, нужно:\n\n'
            '• Полностью пройти $requiredSeason\n'
            '• Или купить подписку',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                );
              },
              child: const Text('Купить подписку'),
            ),
          ],
        ),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lessonId: lessonId,
          userName: _displayName,
          onComplete: () {
            setState(() {
              _loadData();
            });
          },
        ),
      ),
    );
  }

  void _selectSeason(int seasonId) {
    setState(() {
      _expandedSeasonId = null;
      _selectedSeason = seasonId;
      _currentSeasonLessons = LessonDataProvider.getLessonsBySeason(seasonId);
      _loadData();
    });
  }

  void _showSeasonPreview(int seasonId) {
    final season = _seasons.firstWhere((s) => s.id == seasonId);
    final seasonLessons = LessonDataProvider.getLessonsBySeason(seasonId);
    final seasonColors = [
      Colors.deepPurple,
      Colors.teal,
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];
    final color = seasonColors[(seasonId - 1) % seasonColors.length];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: Icon(_getIconData(season.iconName), color: color, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(season.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text('${seasonLessons.length} уроков', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(season.description),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: seasonLessons.length,
                  itemBuilder: (context, index) {
                    final lesson = seasonLessons[index];
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Text('${index+1}', style: TextStyle(color: color))),
                      title: Text(lesson.title, style: const TextStyle(fontSize: 14)),
                      subtitle: Text(lesson.subtitle, maxLines: 1, style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'rocket_launch': return Icons.rocket_launch;
      case 'music_note': return Icons.music_note;
      case 'code': return Icons.code;
      case 'school': return Icons.school;
      default: return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = StorageService.getTotalCompletedLessons();
    final totalLessons = _currentSeasonLessons.length;
    final progress = totalLessons > 0 ? completedCount / totalLessons : 0.0;
    const seasonColor = Colors.deepPurple;

    return Scaffold(
      body: AnimatedGradientBackground(
        colors: [seasonColor.withOpacity(0.15), Colors.purple.withOpacity(0.08), Colors.white],
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(seasonColor, completedCount, totalLessons),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LevelProgressWidget(compact: true),
                      const SizedBox(height: 16),
                      _buildSeasonSelector(),
                      const SizedBox(height: 24),
                      _buildLessonsList(seasonColor, progress),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color seasonColor, int completedCount, int totalLessons) {
    final profile = GamificationService.getProfile();
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.face, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Text('Привет, $_displayName! 👋', style: const TextStyle(fontWeight: FontWeight.bold))),
          _buildHeaderButtons(seasonColor),
        ],
      ),
    );
  }

  Widget _buildHeaderButtons(Color seasonColor) {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.smart_toy, color: Colors.cyan), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatFullScreen(userName: _displayName)))),
        IconButton(icon: const Icon(Icons.family_restroom, color: Colors.indigo), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentDashboardScreen()))),
      ],
    );
  }

  Widget _buildSeasonSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (context, index) {
          final isSelected = _selectedSeason == index + 1;
          return GestureDetector(
            onTap: () => _selectSeason(index + 1),
            child: Container(
              width: 70, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.indigo.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.indigo : Colors.transparent),
              ),
              child: Center(child: Text('СЕЗОН ${index+1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonsList(Color seasonColor, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Карта приключений', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        const SizedBox(height: 32),
        ...List.generate(_currentSeasonLessons.length, (index) {
          final lesson = _currentSeasonLessons[index];
          final isCompleted = StorageService.isLessonCompleted(lesson.id);
          final isAvailable = index == 0 || StorageService.isLessonCompleted(_currentSeasonLessons[index - 1].id);
          final alignment = index % 3;
          final double leftPadding = alignment == 0 ? 0 : (alignment == 1 ? 40 : 80);

          return Padding(
            padding: EdgeInsets.only(left: leftPadding, bottom: 40),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (index < _currentSeasonLessons.length - 1)
                  Positioned(
                    bottom: -45, left: 40,
                    child: CustomPaint(size: const Size(40, 50), painter: PathPainter(color: Colors.grey.withOpacity(0.3), isRight: alignment == 0)),
                  ),
                _LessonCard(
                  lesson: lesson, index: index + 1, isCompleted: isCompleted,
                  isAvailable: isAvailable, iconData: Icons.school, lessonColor: Colors.indigo,
                  onTap: () => _openLesson(lesson.id),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class PathPainter extends CustomPainter {
  final Color color;
  final bool isRight;
  PathPainter({required this.color, required this.isRight});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 4;
    final path = Path();
    if (isRight) { path.moveTo(0, 0); path.quadraticBezierTo(size.width, size.height / 2, size.width / 2, size.height); }
    else { path.moveTo(size.width, 0); path.quadraticBezierTo(0, size.height / 2, size.width / 2, size.height); }
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final bool isCompleted;
  final bool isAvailable;
  final IconData iconData;
  final Color lessonColor;
  final VoidCallback? onTap;

  const _LessonCard({
    required this.lesson,
    required this.index,
    required this.isCompleted,
    required this.isAvailable,
    required this.iconData,
    required this.lessonColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !isAvailable && !isCompleted;
    final color = isLocked ? Colors.grey : (isCompleted ? Colors.green : lessonColor);

    return GestureDetector(
      onTap: (isAvailable || isCompleted) ? onTap : null,
      child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isLocked ? Icons.lock : iconData, color: Colors.white, size: 30),
              Text('Урок $index', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
