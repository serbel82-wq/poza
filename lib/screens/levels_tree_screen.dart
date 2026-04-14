import 'package:flutter/material.dart';
import 'lesson_screen.dart';
import 'final_project_screen.dart';
import 'avatar_selection_screen.dart';
import 'parent_dashboard_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName.isNotEmpty
        ? widget.userName
        : (StorageService.getUserName() ?? 'Исследователь');
    _loadData();
  }

  void _loadData() {
    setState(() {
      _seasons = LessonDataProvider.getSeasons();
      _currentSeasonLessons = LessonDataProvider.getLessonsBySeason(_selectedSeason);
    });
  }

  void _openLesson(int lessonId) {
    SoundService().playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lessonId: lessonId,
          userName: _displayName,
          onComplete: () => _loadData(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = StorageService.getTotalCompletedLessons();
    final totalLessons = _currentSeasonLessons.length;
    final progress = totalLessons > 0 ? completedCount / totalLessons : 0.0;
    const seasonColor = Color(0xFF6C63FF);

    return Scaffold(
      body: AnimatedGradientBackground(
        colors: [seasonColor.withOpacity(0.1), Colors.white],
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressSection(progress, completedCount, totalLessons),
                      const SizedBox(height: 24),
                      _buildSeasonSelector(),
                      const SizedBox(height: 32),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AvatarSelectionScreen())),
            child: const PulseAnimation(
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFF6C63FF),
                child: Icon(Icons.face, color: Colors.white, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Привет, $_displayName!', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const Text('Твое приключение продолжается', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy, color: Colors.cyan),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatFullScreen(userName: _displayName))),
          ),
          IconButton(
            icon: const Icon(Icons.family_restroom, color: Colors.indigo),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentDashboardScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(double progress, int completed, int total) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ТВОЙ ПРОГРЕСС', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
              Text('$completed / $total', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ВЫБЕРИ ЭТАП', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              final isSelected = _selectedSeason == index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSeason = index + 1;
                    _currentSeasonLessons = LessonDataProvider.getLessonsBySeason(_selectedSeason);
                  });
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.withOpacity(0.2)),
                    boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                  ),
                  child: Center(
                    child: Text(
                      'ЭТАП ${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLessonsList(Color seasonColor, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.map, color: Color(0xFF6C63FF)),
            const SizedBox(width: 12),
            const Text('КАРТА ПУТЕШЕСТВИЯ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)),
          ],
        ),
        const SizedBox(height: 32),
        ...List.generate(_currentSeasonLessons.length, (index) {
          final lesson = _currentSeasonLessons[index];
          final isCompleted = StorageService.isLessonCompleted(lesson.id);
          final alignment = index % 2; // Зигзаг: лево-право

          return Padding(
            padding: EdgeInsets.only(
              left: alignment == 0 ? 20 : 120,
              bottom: 40,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (index < _currentSeasonLessons.length - 1)
                  Positioned(
                    bottom: -40,
                    left: 40,
                    child: CustomPaint(
                      size: const Size(40, 40),
                      painter: PathPainter(color: Colors.grey.withOpacity(0.2), isRight: alignment == 0),
                    ),
                  ),
                _LessonCard(
                  lesson: lesson,
                  index: index + 1,
                  isCompleted: isCompleted,
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
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3;
    final path = Path();
    if (isRight) {
      path.moveTo(size.width / 2, 0);
      path.quadraticBezierTo(size.width, size.height / 2, 0, size.height);
    } else {
      path.moveTo(size.width / 2, 0);
      path.quadraticBezierTo(-size.width / 2, size.height / 2, size.width, size.height);
    }
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.index,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? Colors.green : const Color(0xFF6C63FF);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          FloatingWidget(
            animate: !isCompleted,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.white,
                border: Border.all(color: color, width: 3),
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Center(
                child: Icon(isCompleted ? Icons.check : Icons.rocket_launch, color: color, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: Text(
              lesson.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
