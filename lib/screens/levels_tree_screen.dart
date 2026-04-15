import 'package:flutter/material.dart';
import 'lesson_screen.dart';
import 'avatar_selection_screen.dart';
import 'parent_dashboard_screen.dart';
import 'ai_chat_screen.dart';
import '../data/models/lesson.dart';
import '../data/services/storage_service.dart';
import '../data/services/lesson_data_provider.dart';
import '../data/services/sound_service.dart';
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
      _currentSeasonLessons = LessonDataProvider.getLessonsBySeason(_selectedSeason);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = StorageService.getTotalCompletedLessons();
    final totalLessons = _currentSeasonLessons.length;
    final progress = totalLessons > 0 ? completedCount / totalLessons : 0.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF8F9FA), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: Column(
            children: [
              _buildCompactHeader(),
              _buildSeasonBar(),
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      itemCount: _currentSeasonLessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _currentSeasonLessons[index];
                        final isCompleted = StorageService.isLessonCompleted(lesson.id);
                        return Container(
                          width: 130,
                          alignment: Alignment.center,
                          child: _LessonIcon(
                            title: 'Миссия ${index + 1}',
                            isCompleted: isCompleted,
                            onTap: () => _open(lesson.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              _buildBottomProgress(progress, completedCount, totalLessons),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: const Color(0xFF6C63FF), child: IconButton(icon: const Icon(Icons.face, color: Colors.white, size: 18), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AvatarSelectionScreen())))),
          const SizedBox(width: 10),
          Expanded(child: Text('Привет, $_displayName!', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))),
          IconButton(icon: const Icon(Icons.smart_toy, color: Colors.cyan, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatFullScreen(userName: _displayName)))),
          IconButton(icon: const Icon(Icons.family_restroom, color: Colors.indigo, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentDashboardScreen()))),
        ],
      ),
    );
  }

  Widget _buildSeasonBar() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: 8,
        itemBuilder: (context, index) {
          final isSelected = _selectedSeason == index + 1;
          return GestureDetector(
            onTap: () { setState(() { _selectedSeason = index + 1; _loadData(); }); },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: isSelected ? const Color(0xFF6C63FF) : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3))),
              child: Center(child: Text('ЭТАП ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: isSelected ? Colors.white : Colors.grey))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomProgress(double p, int c, int t) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(child: LinearProgressIndicator(value: p, minHeight: 4, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 10),
          Text('$c / $t', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  void _open(int id) {
    SoundService().playClick();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonScreen(lessonId: id, userName: _displayName, onComplete: () => _loadData())));
  }
}

class _LessonIcon extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onTap;
  const _LessonIcon({required this.title, required this.isCompleted, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? Colors.green : const Color(0xFF6C63FF);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? color.withOpacity(0.1) : Colors.white, border: Border.all(color: color, width: 3), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Center(child: Icon(isCompleted ? Icons.check : Icons.rocket_launch, color: color, size: 24)),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
        ],
      ),
    );
  }
}
