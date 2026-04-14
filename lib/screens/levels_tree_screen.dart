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
    final hasAI = subscriptionInfo['hasAIAssistant'] as bool? ?? false;
    final isTrialActive = subscriptionInfo['isTrialActive'] as bool? ?? true;
    
    final freeSeasonLimit = (isSubscribed || isTrialActive) ? 8 : 1;
    
    setState(() {
      _seasons = LessonDataProvider.getSeasons();
      _currentSeasonLessons = LessonDataProvider.getSeason1Lessons();

      _seasons = _seasons.map((season) {
        final completedCount = _currentSeasonLessons
            .where((l) => StorageService.isLessonCompleted(l.id))
            .length;
        final totalLessons = season.id == 1 ? 8 : 6;
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
    // Find which season this lesson belongs to
    final lessonSeason = LessonDataProvider.getSeasons().firstWhere(
      (s) => LessonDataProvider.getLessonsBySeason(s.id).any((l) => l.id == lessonId),
      orElse: () => LessonDataProvider.getSeasons().first,
    );
    
    // Check if the season is unlocked
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

  void _toggleSeasonExpand(int seasonId) {
    setState(() {
      if (_expandedSeasonId == seasonId) {
        _expandedSeasonId = null;
      } else {
        _expandedSeasonId = seasonId;
      }
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
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
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
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_getIconData(season.iconName),
                              color: color, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                season.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${seasonLessons.length} уроков',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (!season.isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock,
                                    size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  'Закрыто',
                                  style: TextStyle(
                                    color: Colors.amber.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      season.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.list, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Уроки в сезоне',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: seasonLessons.length,
                  itemBuilder: (context, index) {
                    final lesson = seasonLessons[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(lesson.title,
                            style: const TextStyle(fontSize: 14)),
                        subtitle: Text(lesson.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12)),
                        trailing: Text('${lesson.durationMinutes} мин',
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (!season.isUnlocked)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                      );
                    },
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Открыть доступ'),
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'music_note':
        return Icons.music_note;
      case 'code':
        return Icons.code;
      case 'school':
        return Icons.school;
      case 'psychology':
        return Icons.psychology;
      case 'edit_note':
        return Icons.edit_note;
      case 'image':
        return Icons.image;
      case 'fact_check':
        return Icons.fact_check;
      case 'security':
        return Icons.security;
      case 'menu_book':
        return Icons.menu_book;
      case 'smart_toy':
        return Icons.smart_toy;
      default:
        return Icons.star;
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
        colors: [
          seasonColor.withOpacity(0.15),
          Colors.purple.withOpacity(0.08),
          Theme.of(context).colorScheme.surface,
        ],
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
                      _buildProgressCard(
                          progress, totalLessons, completedCount, seasonColor),
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
          GestureDetector(
            onTap: () => _openAvatarSelection(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    seasonColor.withOpacity(0.2),
                    seasonColor.withOpacity(0.1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _getAvatarIcon(profile.avatarId),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Привет, $_displayName! 👋',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount из $totalLessons уроков пройдено',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          _buildHeaderButtons(seasonColor),
        ],
      ),
    );
  }

  // AI Assistant button
  Widget _buildHeaderButtons(Color seasonColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _showAIAssistant(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.withOpacity(0.3),
                  Colors.blue.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.smart_toy, color: Colors.cyan.shade700, size: 26),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(Icons.emoji_events, color: seasonColor),
          tooltip: 'Достижения',
          onPressed: () {
            _showAchievementsDialog();
          },
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(Icons.family_restroom, color: seasonColor),
          tooltip: 'Панель родителей',
          onPressed: () => _openParentDashboard(),
        ),
      ],
    );
  }

  void _showAIAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AIChatFullScreen(userName: _displayName),
      ),
    );
  }

  void _openChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(userName: _displayName),
      ),
    );
  }

  void _openParentDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ParentDashboardScreen(),
      ),
    );
  }

  Widget _getAvatarIcon(String avatarId) {
    switch (avatarId) {
      case 'robot_1':
        return const Icon(Icons.smart_toy, color: Colors.deepPurple, size: 24);
      case 'rocket':
        return const Icon(Icons.rocket_launch,
            color: Colors.deepPurple, size: 24);
      case 'brain':
        return const Icon(Icons.psychology, color: Colors.deepPurple, size: 24);
      case 'star':
        return const Icon(Icons.star, color: Colors.amber, size: 24);
      case 'bolt':
        return const Icon(Icons.bolt, color: Colors.orange, size: 24);
      case 'diamond':
        return const Icon(Icons.diamond, color: Colors.blue, size: 24);
      case 'robot_2':
        return const Icon(Icons.android, color: Colors.green, size: 24);
      case 'alien':
        return const Icon(Icons.face, color: Colors.teal, size: 24);
      case 'dragon':
        return const Icon(Icons.pets, color: Colors.red, size: 24);
      case 'wizard':
        return const Icon(Icons.auto_fix_high, color: Colors.purple, size: 24);
      case 'ninja':
        return const Icon(Icons.visibility, color: Colors.grey, size: 24);
      case 'astronaut':
        return const Icon(Icons.nightlight, color: Colors.indigo, size: 24);
      default:
        return const Icon(Icons.smart_toy, color: Colors.deepPurple, size: 24);
    }
  }

  void _openAvatarSelection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AvatarSelectionScreen(),
      ),
    );
  }

  Widget _buildProgressCard(double progress, int totalLessons,
      int completedCount, Color seasonColor) {
    final seasonTitles = [
      'Сезон 1: Первый контакт',
      'Сезон 2: Мир звука и видео'
    ];
    final seasonSubtitles = ['8 уроков + финальный проект', '6 уроков'];

    return Column(
      children: [
        LevelProgressWidget(compact: true),
        const SizedBox(height: 16),
        Card(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  seasonColor.withOpacity(0.1),
                  seasonColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: seasonColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.emoji_events,
                          color: seasonColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seasonTitles[_selectedSeason - 1],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            seasonSubtitles[_selectedSeason - 1],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: seasonColor.withOpacity(0.1),
                    color: seasonColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}% завершено',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: seasonColor,
                          ),
                    ),
                    Text(
                      '$completedCount / $totalLessons',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonSelector() {
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
    final seasonNames = [
      'Сезон 1',
      'Сезон 2',
      'Сезон 3',
      'Сезон 4',
      'Сезон 5',
      'Сезон 6',
      'Сезон 7',
      'Сезон 8',
    ];
    final seasonIcons = [
      Icons.rocket_launch,
      Icons.music_note,
      Icons.code,
      Icons.auto_stories,
      Icons.search,
      Icons.lightbulb,
      Icons.rocket,
      Icons.emoji_events,
    ];
    final seasonLessons = [8, 6, 6, 6, 6, 6, 6, 8];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выбери сезон',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              final isSelected = _selectedSeason == index + 1;
              final isUnlocked = _seasons.length > index
                  ? _seasons[index].isUnlocked
                  : (index == 0);
              final color = seasonColors[index];

              return GestureDetector(
                onTap: isUnlocked
                    ? () => _selectSeason(index + 1)
                    : () => _showSeasonPreview(index + 1),
                onLongPress: () => _showSeasonPreview(index + 1),
                child: Container(
                  width: 75,
                  margin: EdgeInsets.only(right: index < 7 ? 8 : 0),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : isUnlocked
                            ? Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isUnlocked ? seasonIcons[index] : Icons.lock_outline,
                        color: isSelected
                            ? color
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        seasonNames[index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              color: isSelected ? color : null,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        isUnlocked ? '${seasonLessons[index]} ур.' : '🔒',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 9,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
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
            PulseAnimation(
              child: Icon(Icons.map, color: seasonColor, size: 28),
            ),
            const SizedBox(width: 12),
            Text(
              'Карта приключений',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: seasonColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Здесь мы строим зигзаг
        ...List.generate(_currentSeasonLessons.length, (index) {
          final lesson = _currentSeasonLessons[index];
          final isCompleted = StorageService.isLessonCompleted(lesson.id);
          final isAvailable = index == 0 ||
              StorageService.isLessonCompleted(
                  _currentSeasonLessons[index - 1].id);

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
          final colorIndex = lesson.id > 100
              ? (lesson.id - 101) % lessonColors.length
              : (lesson.id - 1) % lessonColors.length;
          final lessonColor = lessonColors[colorIndex];

          // Определяем сторону: 0 - лево, 1 - центр, 2 - право
          final alignment = index % 3;
          final double leftPadding = alignment == 0 ? 0 : (alignment == 1 ? 40 : 80);
          final double rightPadding = alignment == 2 ? 0 : (alignment == 1 ? 40 : 80);

          return Padding(
            padding: EdgeInsets.only(
              left: leftPadding,
              right: rightPadding,
              bottom: 40,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Соединительная линия (тропинка)
                if (index < _currentSeasonLessons.length - 1)
                  Positioned(
                    bottom: -45,
                    left: alignment == 0 ? 60 : (alignment == 1 ? 40 : 20),
                    child: CustomPaint(
                      size: const Size(40, 50),
                      painter: PathPainter(
                        color: seasonColor.withOpacity(0.3),
                        isRight: alignment == 0,
                      ),
                    ),
                  ),
                _LessonCard(
                  lesson: lesson,
                  index: index + 1,
                  isCompleted: isCompleted,
                  isAvailable: isAvailable,
                  iconData: _getIconData(lesson.iconName),
                  lessonColor: lessonColor,
                  onTap: () => _openLesson(lesson.id),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
        if (progress >= 1.0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FloatingWidget(
              child: SizedBox(
                width: double.infinity,
                child: PremiumButton(
                  onPressed: () => _openFinalProject(),
                  icon: Icons.emoji_events,
                  text: 'ФИНАЛЬНЫЙ ПРОЕКТ!',
                  gradientStart: Colors.amber,
                  gradientEnd: Colors.orange,
                ),
              ),
            ),
          ),
      ],
    );
  }

// Специальный художник для тропинки между уровнями
class PathPainter extends CustomPainter {
  final Color color;
  final bool isRight;

  PathPainter({required this.color, required this.isRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isRight) {
      path.moveTo(0, 0);
      path.quadraticBezierTo(size.width, size.height / 2, size.width / 2, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.quadraticBezierTo(0, size.height / 2, size.width / 2, size.height);
    }

    // Рисуем пунктир
    final dashPath = Path();
    double distance = 0.0;
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + 5),
          Offset.zero,
        );
        distance += 10;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

  void _openFinalProject() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FinalProjectScreen(
          seasonId: _selectedSeason,
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

  void _showAchievementsDialog() {
    final unlockedAchievements = GamificationService.getUnlockedAchievements();
    final lockedAchievements = GamificationService.getLockedAchievements();
    final stats = GamificationService.getGamificationStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
                'Достижения (${unlockedAchievements.length}/${stats['totalAchievements']})'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (unlockedAchievements.isNotEmpty) ...[
                const Text('Полученные:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...unlockedAchievements.map((a) => ListTile(
                      leading: Icon(
                        _getAchievementIcon(a.iconName),
                        color: a.isRare ? Colors.amber : Colors.green,
                      ),
                      title: Text(a.title),
                      subtitle: Text(a.description,
                          style: const TextStyle(fontSize: 12)),
                    )),
                const Divider(),
              ],
              if (lockedAchievements.isNotEmpty) ...[
                const Text('Заблокированные:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...lockedAchievements.take(5).map((a) => ListTile(
                      leading: Icon(
                        _getAchievementIcon(a.iconName),
                        color: Colors.grey,
                      ),
                      title: Text(a.title,
                          style: const TextStyle(color: Colors.grey)),
                      subtitle: Text(a.description,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'psychology':
        return Icons.psychology;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'quiz':
        return Icons.quiz;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'music_note':
        return Icons.music_note;
      case 'auto_fix_high':
        return Icons.auto_fix_high;
      case 'explore':
        return Icons.explore;
      case 'school':
        return Icons.school;
      case 'military_tech':
        return Icons.military_tech;
      case 'diamond':
        return Icons.diamond;
      case 'trending_up':
        return Icons.trending_up;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'blocks':
        return Icons.hub;
      case 'palette':
        return Icons.palette;
      case 'edit_note':
        return Icons.edit_note;
      case 'security':
        return Icons.security;
      case 'family_restroom':
        return Icons.family_restroom;
      default:
        return Icons.emoji_events;
    }
  }
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
    final isLocked = !widget.isAvailable && !widget.isCompleted;
    final color = isLocked ? Colors.grey : (widget.isCompleted ? Colors.green : widget.lessonColor);

    return Column(
      children: [
        GestureDetector(
          onTap: (widget.isAvailable || widget.isCompleted) ? widget.onTap : null,
          child: FloatingWidget(
            animate: widget.isAvailable && !widget.isCompleted,
            floatDistance: 8,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isCompleted)
                    const Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.check, color: Colors.green, size: 18),
                      ),
                    ),
                  Icon(
                    isLocked ? Icons.lock_outline : widget.iconData,
                    color: Colors.white,
                    size: 40,
                  ),
                  // Номер урока
                  Positioned(
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Урок ${widget.index}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 140,
          child: Text(
            widget.lesson.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isLocked ? Colors.grey : null,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
