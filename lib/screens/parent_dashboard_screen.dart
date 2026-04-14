import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_screen.dart';
import '../data/services/chat_service.dart';
import '../data/services/gamification_service.dart';
import '../data/services/lesson_data_provider.dart';
import '../widgets/premium_animations.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  static SharedPreferences? _prefs;
  static SharedPreferences get prefs => _prefs!;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final stats = GamificationService.getGamificationStats();
    final profile = GamificationService.getProfile();
    final unlockedAchievements = GamificationService.getUnlockedAchievements();
    final aiChatHistory = ChatService().getAiChatHistory();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('КОНТРОЛЬ ПОЛЁТА', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(profile.name, stats['level'] as int),
            const SizedBox(height: 24),
            _buildSectionTitle('ОСНОВНЫЕ ПОКАЗАТЕЛИ'),
            const SizedBox(height: 12),
            _buildStatsGrid(context, stats),
            const SizedBox(height: 24),
            _buildSectionTitle('ИНТЕРЕСЫ И ВОПРОСЫ'),
            const SizedBox(height: 12),
            _buildAiTopicsCard(context, aiChatHistory),
            const SizedBox(height: 24),
            _buildSectionTitle('ДОСТИЖЕНИЯ И ПРОГРЕСС'),
            const SizedBox(height: 12),
            _buildAchievementsProgress(context, unlockedAchievements, stats),
            const SizedBox(height: 24),
            _buildSectionTitle('УПРАВЛЕНИЕ'),
            const SizedBox(height: 12),
            _buildSettingsCard(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, int level) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF6C63FF),
            child: Icon(Icons.face, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text('Уровень $level Исследователя', style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.verified, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('УРОКИ', '${stats['totalLessonsCompleted']}', Icons.school, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('XP', '${stats['totalXpEarned']}', Icons.stars, Colors.amber)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('ДНИ', '${stats['currentStreak']}', Icons.local_fire_department, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAiTopicsCard(BuildContext context, List<Map<String, dynamic>> history) {
    final questions = history.where((m) => m['role'] == 'user').toList().reversed.toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: Colors.purple),
              SizedBox(width: 12),
              Text('О ЧЕМ СПРАШИВАЛ РЕБЕНОК?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          if (questions.isEmpty)
            const Text('Ребенок еще не задавал вопросов ИИ.', style: TextStyle(color: Colors.grey))
          else
            ...questions.take(3).map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: Text('"${q['content']}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildAchievementsProgress(BuildContext context, List unlocked, Map<String, dynamic> stats) {
    final total = stats['totalAchievements'] as int;
    final count = unlocked.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ОТКРЫТЫЕ ДОСТИЖЕНИЯ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              Text('$count / $total', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 10,
              backgroundColor: Colors.amber.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          _buildSettingsTile(Icons.card_membership, 'Подписка и оплата', 'Управление тарифами', () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
          }),
          _buildSettingsTile(Icons.security, 'Правила безопасности', 'Для родителей и детей', () => _openSafetyRules(context)),
          _buildSettingsTile(Icons.help_outline, 'Поддержка', 'Написать нам в Telegram', () {}),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Future<void> _openSafetyRules(BuildContext context) async {
    final url = Uri.parse('https://serbel82-wq.github.io/new-neuro-explorer/docs/Правила_безопасности_для_родителей.html');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }
}

