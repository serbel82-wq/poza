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
  List<Lesson> _lessons = [];
  int _season = 1;

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName.isNotEmpty ? widget.userName : (StorageService.getUserName() ?? 'Исследователь');
    _load();
  }

  void _load() {
    setState(() {
      _lessons = LessonDataProvider.getLessonsBySeason(_season);
    });
  }

  @override
  Widget build(BuildContext context) {
    final done = StorageService.getTotalCompletedLessons();
    final total = _lessons.length;
    final progress = total > 0 ? done / total : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTop(),
            _buildSeasons(),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _lessons.length,
                itemBuilder: (context, i) {
                  final l = _lessons[i];
                  final isDone = StorageService.isLessonCompleted(l.id);
                  return _Item(title: 'Миссия ${i + 1}', isDone: isDone, onTap: () => _open(l.id));
                },
              ),
            ),
            _buildProgress(progress, done, total),
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AvatarSelectionScreen())), child: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.face, color: Colors.white))),
          const SizedBox(width: 10),
          Expanded(child: Text('Привет, $_displayName!', style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.smart_toy, color: Colors.cyan), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatFullScreen(userName: _displayName)))),
          IconButton(icon: const Icon(Icons.family_restroom, color: Colors.indigo), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentDashboardScreen()))),
        ],
      ),
    );
  }

  Widget _buildSeasons() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (context, i) {
          final sel = _season == i + 1;
          return GestureDetector(
            onTap: () { setState(() { _season = i + 1; _load(); }); },
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: sel ? Colors.indigo : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.indigo.withOpacity(0.2))),
              child: Center(child: Text('ЭТАП ${i + 1}', style: TextStyle(color: sel ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 10))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgress(double p, int c, int t) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(child: LinearProgressIndicator(value: p, minHeight: 6, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 10),
          Text('$c / $t', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  void _open(int id) {
    SoundService().playClick();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonScreen(lessonId: id, userName: _displayName, onComplete: () => _load())));
  }
}

class _Item extends StatelessWidget {
  final String title;
  final bool isDone;
  final VoidCallback onTap;
  const _Item({required this.title, required this.isDone, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isDone ? Colors.green.withOpacity(0.1) : Colors.white, border: Border.all(color: isDone ? Colors.green : Colors.indigo, width: 3)),
            child: Icon(isDone ? Icons.check : Icons.rocket_launch, color: isDone ? Colors.green : Colors.indigo, size: 30),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
