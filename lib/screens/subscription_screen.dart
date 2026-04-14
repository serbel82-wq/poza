import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/payment_provider.dart';
import '../data/services/firebase_service.dart';
import '../widgets/premium_animations.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PaymentProvider _paymentProvider = YooKassaPaymentProvider();
  bool _isLoading = false;
  String? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    final subscriptionInfo = SubscriptionService().getSubscriptionInfo();
    final isSubscribed = subscriptionInfo['isSubscribed'] as bool;
    final isTrialActive = subscriptionInfo['isTrialActive'] as bool;
    final trialDaysRemaining = subscriptionInfo['trialDaysRemaining'] as int;

    return Scaffold(
      body: AnimatedGradientBackground(
        colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.1),
          Colors.white,
        ],
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (isSubscribed || isTrialActive)
                            _buildCurrentStatus(subscriptionInfo),
                          const SizedBox(height: 24),
                          _buildTrialHero(trialDaysRemaining, isTrialActive),
                          const SizedBox(height: 32),
                          _buildSectionHeader('ВЫБЕРИ СВОЮ СУПЕРСИЛУ'),
                          const SizedBox(height: 16),
                          _buildPlanGrid(),
                          const SizedBox(height: 32),
                          if (_selectedPlan != null) 
                            FadeTransition(
                              opacity: const AlwaysStoppedAnimation(1),
                              child: _buildPaymentCallToAction(),
                            ),
                          const SizedBox(height: 32),
                          _buildFeaturesCard(),
                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      title: const Text(
        'ЦЕНТР ПОДГОТОВКИ',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Center(
      child: NeonText(
        text: title,
        neonColor: Theme.of(context).colorScheme.primary,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildCurrentStatus(Map<String, dynamic> info) {
    final isTrial = info['isTrialActive'] as bool;
    return GlassCard(
      backgroundColor: Colors.green.withOpacity(0.1),
      child: Row(
        children: [
          const PulseAnimation(
            child: Icon(Icons.verified, color: Colors.green, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTrial ? 'АКТИВИРОВАН ТЕСТ-ДРАЙВ' : 'ПРЕМИУМ ДОСТУП',
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green),
              ),
              Text(
                isTrial ? 'Осталось дней: ${info['trialDaysRemaining']}' : 'Подписка активна',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrialHero(int daysRemaining, bool isActive) {
    if (isActive) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD166), Color(0xFFFF9F1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'ПОДАРОК НОВИЧКУ!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'Получи 7 дней полного доступа ко всем урокам бесплатно!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _activateTrial,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('ЗАБРАТЬ ПОДАРОК', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanGrid() {
    return Column(
      children: [
        _buildHeroPlan(
          'СУПЕР-ИНТЕЛЛЕКТ',
          '499 ₽',
          'МЕСЯЦ + БЕЗЛИМИТНЫЙ ИИ',
          true,
          'S-INTEL',
          Colors.cyan,
          Icons.bolt,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmallPlan(
                'БАЗОВЫЙ',
                '199 ₽',
                'МЕСЯЦ',
                'BASIC-M',
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallPlan(
                'ГОДОВОЙ',
                '1490 ₽',
                'ВЫГОДНО',
                'BASIC-Y',
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSmallPlan(
          'ВЕЧНЫЙ ДОСТУП (ВСЕ 8 СЕЗОНОВ)',
          '2500 ₽',
          'НАВСЕГДА',
          'LIFETIME',
          Colors.amber.shade800,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildHeroPlan(String title, String price, String subtitle, bool isPopular, String id, Color color, IconData icon) {
    final isSelected = _selectedPlan == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: AnimatedBorder(
        borderColor: color,
        borderWidth: isSelected ? 4 : 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? color : color.withOpacity(0.2), width: 2),
          ),
          child: Row(
            children: [
              PulseAnimation(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 32),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color)),
                    Text(subtitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(price, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallPlan(String title, String price, String subtitle, String id, Color color, {bool isWide = false}) {
    final isSelected = _selectedPlan == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.2), width: 2),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? color : Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text(price, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            Text(subtitle, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCallToAction() {
    return Column(
      children: [
        const Icon(Icons.arrow_downward, color: Colors.grey),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: PremiumButton(
            text: 'ПЕРЕЙТИ К ОПЛАТЕ',
            icon: Icons.shopping_cart,
            onPressed: _startPayment,
            gradientStart: Theme.of(context).colorScheme.primary,
            gradientEnd: Colors.purple,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Безопасная оплата через YooKassa (Карты, СБП)',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFeaturesCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ЧТО ТЫ ПОЛУЧИШЬ:', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildFeatureRow(Icons.rocket_launch, 'Доступ ко всем 8 сезонам обучения'),
          _buildFeatureRow(Icons.smart_toy, 'Личный ИИ-помощник (в тарифе Супер)'),
          _buildFeatureRow(Icons.star, 'Эксклюзивные аватары и бейджи'),
          _buildFeatureRow(Icons.family_restroom, 'Панель для контроля родителями'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _activateTrial() async {
    setState(() => _isLoading = true);
    await SubscriptionService().activateTrial();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пакет новичка активирован! Приятного обучения!'), backgroundColor: Colors.green),
      );
      setState(() {});
    }
    setState(() => _isLoading = false);
  }

  Future<void> _startPayment() async {
    if (_selectedPlan == null) return;
    
    setState(() => _isLoading = true);
    
    int amount = 0;
    String desc = "";
    bool ai = false;
    
    switch(_selectedPlan) {
      case 'S-INTEL': amount = 499; desc = "Тариф Супер-Интеллект"; ai = true; break;
      case 'BASIC-M': amount = 199; desc = "Базовый месяц"; break;
      case 'BASIC-Y': amount = 1490; desc = "Базовый год"; break;
      case 'LIFETIME': amount = 2500; desc = "Вечный доступ"; break;
    }

    try {
      final redirectUrl = await _paymentProvider.initiatePayment(
        planId: _selectedPlan!, amount: amount, description: desc,
      );

      if (redirectUrl != null) {
        await SubscriptionService().subscribe(
          months: _selectedPlan!.contains('Y') ? 12 : 1,
          paymentMethodId: 'demo', withAI: ai,
        );
        if (mounted) setState(() {});
        if (await canLaunchUrl(Uri.parse(redirectUrl))) {
          await launchUrl(Uri.parse(redirectUrl), webOnlyWindowName: '_blank');
        }
      }
    } catch (e) {
      debugPrint("Payment error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

