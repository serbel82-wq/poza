import 'package:flutter/material.dart';
import '../data/services/gamification_service.dart';
import '../data/services/sound_service.dart';
import '../widgets/premium_animations.dart';

class Avatar {
  final String id;
  final String name;
  final IconData icon;
  final int cost;
  final bool isDefault;
  final Color color;

  const Avatar({
    required this.id,
    required this.name,
    required this.icon,
    this.cost = 0,
    this.isDefault = false,
    this.color = Colors.blue,
  });
}

class AvatarSelectionScreen extends StatefulWidget {
  final Function(String)? onSelect;

  const AvatarSelectionScreen({super.key, this.onSelect});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  static const List<Avatar> _allAvatars = [
    // Free avatars
    Avatar(id: 'robot_1', name: 'Робот', icon: Icons.smart_toy, isDefault: true, color: Colors.indigo),
    Avatar(id: 'kid', name: 'Новичок', icon: Icons.waving_hand, cost: 0, color: Colors.green),
    // Premium avatars - buy with stars
    Avatar(id: 'scientist', name: 'Учёный', icon: Icons.science, cost: 50, color: Colors.teal),
    Avatar(id: 'coder', name: 'Кодер', icon: Icons.code, cost: 80, color: Colors.blueGrey),
    Avatar(id: 'rocket', name: 'Пилот', icon: Icons.rocket_launch, cost: 100, color: Colors.deepOrange),
    Avatar(id: 'brain', name: 'Гений', icon: Icons.psychology, cost: 120, color: Colors.purple),
    Avatar(id: 'alien', name: 'НЛО', icon: Icons.face, cost: 150, color: Colors.lightGreen),
    Avatar(id: 'robot_bot', name: 'Дроид', icon: Icons.smart_toy, cost: 180, color: Colors.blue),
    Avatar(id: 'star', name: 'Звезда', icon: Icons.star, cost: 200, color: Colors.amber),
    Avatar(id: 'bolt', name: 'Молния', icon: Icons.bolt, cost: 220, color: Colors.orange),
    Avatar(id: 'dragon', name: 'Дракон', icon: Icons.pets, cost: 250, color: Colors.red),
    Avatar(id: 'wizard', name: 'Маг', icon: Icons.auto_fix_high, cost: 300, color: Colors.deepPurple),
    Avatar(id: 'ninja', name: 'Ниндзя', icon: Icons.visibility, cost: 350, color: Colors.black87),
    Avatar(id: 'astronaut', name: 'Лунатик', icon: Icons.nightlight, cost: 400, color: Colors.indigoAccent),
    Avatar(id: 'king', name: 'Король', icon: Icons.workspace_premium, cost: 450, color: Colors.amberAccent),
    Avatar(id: 'diamond', name: 'Алмаз', icon: Icons.diamond, cost: 500, color: Colors.lightBlueAccent),
    Avatar(id: 'superhero', name: 'Герой', icon: Icons.shield, cost: 550, color: Colors.redAccent),
    Avatar(id: 'magic', name: 'Магия', icon: Icons.auto_awesome, cost: 600, color: Colors.pinkAccent),
    Avatar(id: 'android', name: 'Битбот', icon: Icons.android, cost: 650, color: Colors.greenAccent),
    Avatar(id: 'happy', name: 'Смайл', icon: Icons.sentiment_very_satisfied, cost: 700, color: Colors.yellow),
    Avatar(id: 'cat', name: 'Котик', icon: Icons.pets, cost: 750, color: Colors.orangeAccent),
    Avatar(id: 'robot2', name: 'Т-800', icon: Icons.smart_toy, cost: 800, color: Colors.blueGrey),
    Avatar(id: 'lightning', name: 'Флэш', icon: Icons.flash_on, cost: 850, color: Colors.yellowAccent),
    Avatar(id: 'castle', name: 'Замок', icon: Icons.castle, cost: 900, color: Colors.pink),
    Avatar(id: 'sports', name: 'Лидер', icon: Icons.emoji_events, cost: 1000, color: Colors.amber),
  ];

  @override
  Widget build(BuildContext context) {
    final profile = GamificationService.getProfile();
    final stats = GamificationService.getGamificationStats();
    final currentXp = stats['totalXpEarned'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбери своего героя'),
        centerTitle: true,
      ),
      body: AnimatedGradientBackground(
        colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.05),
          Theme.of(context).colorScheme.surface,
        ],
        child: Column(
          children: [
            // Панель XP
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingWidget(
                floatDistance: 5,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.amber.withOpacity(0.1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PulseAnimation(
                        child: Icon(Icons.stars, color: Colors.amber, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Твой опыт',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$currentXp XP',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _allAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = _allAvatars[index];
                  final isOwned = avatar.isDefault || currentXp >= avatar.cost;
                  final isSelected = profile.avatarId == avatar.id;

                  return _AvatarCard(
                    avatar: avatar,
                    isOwned: isOwned,
                    isSelected: isSelected,
                    onTap: isOwned
                        ? () => _selectAvatar(avatar.id)
                        : () => _showNotEnoughXpDialog(avatar),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAvatar(String avatarId) async {
    SoundService().playSuccess();
    await GamificationService.setAvatar(avatarId);
    if (mounted) {
      setState(() {});
      widget.onSelect?.call(avatarId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Новый герой выбран!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    }
  }

  void _showNotEnoughXpDialog(Avatar avatar) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: avatar.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(avatar.icon, size: 60, color: avatar.color),
              ),
              const SizedBox(height: 16),
              Text(
                'Герой заблокирован',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Тебе нужно ${avatar.cost} XP, чтобы открыть героя ${avatar.name}. Продолжай учиться!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PremiumButton(
                  text: 'Понятно!',
                  onPressed: () => Navigator.pop(context),
                  gradientStart: avatar.color,
                  gradientEnd: avatar.color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final Avatar avatar;
  final bool isOwned;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarCard({
    required this.avatar,
    required this.isOwned,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOwned ? avatar.color : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected 
                  ? [color, color.withOpacity(0.6)]
                  : [Colors.white, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? color.withOpacity(0.4) : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 20 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: isSelected ? Colors.white : (isOwned ? color.withOpacity(0.1) : Colors.transparent),
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PulseAnimation(
                  animate: isSelected,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.3) : color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      avatar.icon,
                      size: 36,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  avatar.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : (isOwned ? Colors.black87 : Colors.grey),
                  ),
                ),
                if (!avatar.isDefault && !isSelected) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOwned ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars,
                          size: 14,
                          color: isOwned ? Colors.amber.shade700 : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${avatar.cost}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOwned ? Colors.amber.shade700 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSelected)
            const Positioned(
              top: -8,
              right: -8,
              child: FloatingWidget(
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
            ),
          if (!isOwned)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.lock, color: Colors.grey.withOpacity(0.5), size: 20),
            ),
        ],
      ),
    );
  }
}
