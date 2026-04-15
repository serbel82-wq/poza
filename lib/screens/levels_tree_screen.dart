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
  const LevelsTreeScreen({super.key, this.userName = '', this.initialLessonId});
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
    _displayName = widget.userName.isNotEmpty ? widget.userName : (StorageService.getUserName() ?? 'Исследователь');
    _loadData();
  }

  void _loadData() {
    setState(() {
      _seasons = LessonDataProvider.getSeasons();
      _currentSeasonLessons = LessonDataProvider.getLessonsBySeason(_selectedSeason);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = StorageService.getTotalCompletedLessons();
    final totalLessons = _currentSeasonLessons.length;
    final progress = totalLessons > 0 ? completedCount / totalLessons : 0.0;
    const seasonColor = Color(0xFF6C63FF);

    return Scaffold(
      body: AnimatedGradientBackground(
        colors: [seasonColor.withOpacity(0.05), Colors.white],
        child: SafeArea(
          child: Column(
            children: [
              _buildCompactHeader(),
              _buildTinySeasonSelector(),
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 250, // Фиксированная высота для карты
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      itemCount: _currentSeasonLessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _currentSeasonLessons[index];
                        final isCompleted = StorageService.isLessonCompleted(lesson.id);
                        // Зигзаг по вертикали внутри горизонтальной ленты
                        final double yOffset = index % 2 == 0 ? -30 : 30;
                        
                        return Container(
                          width: 160,
                          alignment: Alignment.center,
                          child: Transform.translate(
                            offset: Offset(0, yOffset),
                            child: _LessonCardCompact(
                              lesson: lesson,
                              index: index + 1,
                              isCompleted: isCompleted,
                              onTap: () => _openLesson(lesson.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              _buildBottomStats(progress, completedCount, totalLessons),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AvatarSelectionScreen())),
            child: const CircleAvatar(radius: 20, backgroundColor: Color(0xFF6C63FF), child: Icon(Icons.face, color: Colors.white, size: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Привет, $_displayName!', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
          IconButton(icon: const Icon(Icons.smart_toy, color: Colors.cyan, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatFullScreen(userName: _displayName)))),
          IconButton(icon: const Icon(Icons.family_restroom, color: Colors.indigo, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentDashboardScreen()))),
        ],
      ),
    );
  }

  Widget _buildTinySeasonSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
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
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.withOpacity(0.2)),
              ),
              child: Center(child: Text('ЭТАП ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isSelected ? Colors.white : Colors.grey))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomStats(double progress, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: Colors.grey.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF))),
            ),
          ),
          const SizedBox(width: 15),
          Text('$completed / $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF6C63FF))),
        ],
      ),
    );
  }

  void _openLesson(int lessonId) {
    SoundService().playClick();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonScreen(lessonId: lessonId, userName: _displayName, onComplete: () => _loadData())));
  }
}

class _LessonCardCompact extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final bool isCompleted;
  final VoidCallback onTap;
  const _LessonCardCompact({required this.lesson, required this.index, required this.isCompleted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? Colors.green : const Color(0xFF6C63FF);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingWidget(
            animate: !isCompleted,
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.white,
                border: Border.all(color: color, width: 3),
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Center(child: Icon(isCompleted ? Icons.check : Icons.rocket_launch, color: color, size: 24)),
            ),
          ),
          const SizedBox(height: 8),
          Text('Миссия $index', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
          const SizedBox(height: 2),
          SizedBox(width: 120, child: Text(lesson.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
