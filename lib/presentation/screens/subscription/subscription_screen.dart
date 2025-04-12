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
        child: Column(
          children: [
            // Header with gift box icon
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.navyBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: AppColors.limeGreen,
                        size: 40,
                      ),
                    ).animate().fadeIn().scale(
                          delay: const Duration(milliseconds: 100),
                          duration: const Duration(milliseconds: 300),
                        ),
                    const SizedBox(height: 24),
                    const Text(
                      'Choose your plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideY(
                          begin: 0.2,
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 300),
                        ),
                    const SizedBox(height: 10),
                    const Text(
                      '7 DAY FREE TRIAL',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn().slideY(
                          begin: 0.2,
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 300),
                        ),
                  ],
                ),
              ),
            ),

            // Subscription options
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: ValueListenableBuilder<SubscriptionPlan>(
                  valueListenable: selectedPlan,
                  builder: (context, plan, _) {
                    return Column(
                      children: [
                        // Weekly plan
                        _buildSubscriptionOption(
                          title: 'Weekly',
                          subtitle: 'Billed monthly no trial',
                          price: '\$FREE',
                          period: '/ Trial',
                          isSelected: plan == SubscriptionPlan.weekly,
                          isRecommended: false,
                          onTap: () =>
                              selectedPlan.value = SubscriptionPlan.weekly,
                        ).animate().fadeIn().slideY(
                              begin: 0.1,
                              delay: const Duration(milliseconds: 400),
                              duration: const Duration(milliseconds: 300),
                            ),

                        const SizedBox(height: 16),

                        // Monthly plan (recommended)
                        _buildSubscriptionOption(
                          title: 'Monthly',
                          subtitle: 'Billed monthly no trial',
                          price: '\$20',
                          period: '/ month',
                          isSelected: plan == SubscriptionPlan.monthly,
                          isRecommended: false,
                          onTap: () =>
                              selectedPlan.value = SubscriptionPlan.monthly,
                        ).animate().fadeIn().slideY(
                              begin: 0.1,
                              delay: const Duration(milliseconds: 500),
                              duration: const Duration(milliseconds: 300),
                            ),

                        const SizedBox(height: 16),

                        // Yearly plan
                        _buildSubscriptionOption(
                          title: 'Yearly',
                          subtitle: 'Billed yearly no trial',
                          price: '\$100',
                          period: '/ year',
                          isSelected: plan == SubscriptionPlan.yearly,
                          isRecommended: false,
                          onTap: () =>
                              selectedPlan.value = SubscriptionPlan.yearly,
                        ).animate().fadeIn().slideY(
                              begin: 0.1,
                              delay: const Duration(milliseconds: 600),
                              duration: const Duration(milliseconds: 300),
                            ),

                        const Spacer(),

                        // Info text
                        const Text(
                          'Cancel anytime in the App store',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.limeGreen,
                              foregroundColor: AppColors.navyBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              await subscriptionNotifier.subscribe(plan);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Successfully subscribed to ${plan.name} plan!',
                                      style:
                                          const TextStyle(color: Colors.white),
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
                            child: Text(
                              _getButtonText(plan),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ).animate().fadeIn().slideY(
                              begin: 0.2,
                              delay: const Duration(milliseconds: 700),
                              duration: const Duration(milliseconds: 300),
                            ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.weekly:
        return 'Continue with FREE Trial';
      case SubscriptionPlan.monthly:
        return 'Continue with \$20/month';
      case SubscriptionPlan.yearly:
        return 'Continue with \$100/year';
      default:
        return 'Continue';
    }
  }

  Widget _buildSubscriptionOption({
    required String title,
    required String subtitle,
    required String price,
    required String period,
    required bool isSelected,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.limeGreen : Colors.white24,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? AppColors.navyBlue.withOpacity(0.5)
            : AppColors.navyBlue.withOpacity(0.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          period,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isRecommended)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.limeGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'RECOMMENDED',
                        style: TextStyle(
                          color: AppColors.navyBlue,
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
    );
  }
}
