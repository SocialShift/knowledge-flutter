import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/data/providers/subscription_provider.dart';

class SubscriptionScreen extends HookConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final subscriptionNotifier =
        ref.watch(subscriptionNotifierProvider.notifier);
    final selectedPlan =
        ValueNotifier<SubscriptionPlan>(SubscriptionPlan.monthly);

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with owl mascot
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.limeGreen.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo/logo.png',
                        width: 60,
                        height: 60,
                      ),
                    ).animate().fadeIn().scale(
                          delay: const Duration(milliseconds: 100),
                          duration: const Duration(milliseconds: 300),
                        ),
                    const SizedBox(height: 20),
                    Text(
                      'Super learners are 4.2x more\nlikely to finish the Relevent Stories!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideY(
                          begin: 0.2,
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 300),
                        ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Features Comparison Table
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Table Header
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          const Expanded(
                            flex: 5,
                            child: Text(
                              'Feature',
                              style: TextStyle(
                                color: AppColors.navyBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 28,
                              alignment: Alignment.center,
                              child: const Text(
                                'FREE',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 28,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.limeGreen,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  color: AppColors.navyBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                        height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

                    // Features List
                    _buildFeatureRow(
                      title: 'Learning content',
                      freeValue: true,
                      proValue: true,
                    ),
                    _buildFeatureRow(
                      title: 'Unlimited Hearts',
                      freeValue: false,
                      proValue: true,
                    ),
                    _buildFeatureRow(
                      title: 'No ads',
                      freeValue: false,
                      proValue: true,
                    ),
                    _buildFeatureRow(
                      title: 'Skills practice',
                      freeValue: true,
                      proValue: true,
                    ),
                    _buildFeatureRow(
                      title: 'Mistakes review',
                      freeValue: true,
                      proValue: true,
                    ),
                    _buildFeatureRow(
                      title: 'Free challenge entry',
                      freeValue: false,
                      proValue: true,
                    ),
                    _buildFeatureRow(
                      title: 'Core Stories',
                      subtitle: 'Access to historical archives',
                      freeValue: '1-2 new entries/day',
                      proValue: 'Unlimited, full archive',
                    ),
                    _buildFeatureRow(
                      title: 'Interactive Timeline',
                      freeValue: 'Partial access',
                      proValue: 'Full access with filters',
                    ),
                    _buildFeatureRow(
                      title: 'Game Center Access',
                      freeValue: '1 game/day',
                      proValue: 'Unlimited play',
                    ),
                    _buildFeatureRow(
                      title: 'Audio & Video Stories',
                      freeValue: false,
                      proValue: true,
                    ),
                    _buildFeatureRow(
                      title: '"On This Day" Alerts',
                      freeValue: 'Weekly',
                      proValue: 'Daily & personalized',
                    ),
                    _buildFeatureRow(
                      title: 'Badges & Streaks',
                      freeValue: 'Starter set only',
                      proValue: 'Unlock all rewards',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Subscribe Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.limeGreen,
                      foregroundColor: AppColors.navyBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await subscriptionNotifier
                          .subscribe(SubscriptionPlan.monthly);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Starting your free trial!',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: AppColors.navyBlue,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(12),
                          ),
                        );
                        context.pop();
                      }
                    },
                    child: const Text(
                      'START MY FREE WEEK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // No Thanks Button
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'NO THANKS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required String title,
    String? subtitle,
    dynamic freeValue,
    dynamic proValue,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navyBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: _buildValueWidget(freeValue),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: _buildValueWidget(proValue, isPro: true),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  Widget _buildValueWidget(dynamic value, {bool isPro = false}) {
    if (value is bool) {
      return value
          ? Icon(
              Icons.check,
              color: isPro ? AppColors.limeGreen : Colors.grey.shade600,
              size: 20,
            )
          : const Icon(
              Icons.close,
              color: Colors.grey,
              size: 20,
            );
    } else if (value is String) {
      return Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isPro ? AppColors.limeGreen : Colors.grey.shade600,
          fontSize: 12,
          fontWeight: isPro ? FontWeight.bold : FontWeight.normal,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
