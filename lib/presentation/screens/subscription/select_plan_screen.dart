import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_colors.dart';
import 'package:knowledge/data/providers/subscription_provider.dart';

class SelectPlanScreen extends ConsumerStatefulWidget {
  const SelectPlanScreen({super.key});

  @override
  ConsumerState<SelectPlanScreen> createState() => _SelectPlanScreenState();
}

class _SelectPlanScreenState extends ConsumerState<SelectPlanScreen> {
  int _selectedIndex = 1; // Default to yearly plan (better value)

  final List<PlanOption> _plans = [
    PlanOption(
      title: 'Monthly',
      productId: 'pro_subscription_1month',
      price: '\$12',
      period: 'month',
      yearlyEquivalent: '\$144 / year',
      isPopular: false,
    ),
    PlanOption(
      title: 'Yearly',
      productId: 'pro_subscription_1y',
      price: '\$99',
      period: 'year',
      yearlyEquivalent: 'Save \$45',
      isPopular: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.primaryBlue.withOpacity(0.95) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          color: isDarkMode ? Colors.white : AppColors.primaryBlue,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.purpleAccent,
                  ],
                ),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Choose your plan',
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode ? Colors.white : AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No free trial. Cancel anytime.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Plan cards
                      ...List.generate(_plans.length, (index) {
                        final plan = _plans[index];
                        return _PlanCard(
                          plan: plan,
                          selected: _selectedIndex == index,
                          onTap: () => setState(() => _selectedIndex = index),
                        );
                      }),

                      const Spacer(),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.1,
                            ),
                            elevation: 0,
                          ),
                          onPressed: subscriptionState.isLoading
                              ? null
                              : () {
                                  final selectedPlan = _plans[_selectedIndex];
                                  _handleSubscription(selectedPlan);
                                },
                          child: subscriptionState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryBlue),
                                  ),
                                )
                              : Text(
                                  'SUBSCRIBE FOR ${_plans[_selectedIndex].price}/${_plans[_selectedIndex].period.toUpperCase()}'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Terms and privacy
                      Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy. Subscription automatically renews unless cancelled.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleSubscription(PlanOption plan) async {
    final subscriptionNotifier =
        ref.read(subscriptionNotifierProvider.notifier);

    // Convert PlanOption to SubscriptionPlan
    SubscriptionPlan subscriptionPlan;
    if (plan.productId == 'pro_subscription_1month') {
      subscriptionPlan = SubscriptionPlan.monthly;
    } else if (plan.productId == 'pro_subscription_1y') {
      subscriptionPlan = SubscriptionPlan.yearly;
    } else {
      subscriptionPlan = SubscriptionPlan.free;
    }

    // Show loading
    setState(() {});

    try {
      final success = await subscriptionNotifier.subscribe(subscriptionPlan);

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully subscribed to ${plan.title} plan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Close the screen
        Navigator.of(context).pop();
      } else if (mounted) {
        // Show error message
        final subscriptionState = ref.read(subscriptionNotifierProvider);
        final errorMessage = subscriptionState.error ?? 'Subscription failed';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class PlanOption {
  final String title;
  final String productId;
  final String price;
  final String period;
  final String yearlyEquivalent;
  final bool isPopular;

  PlanOption({
    required this.title,
    required this.productId,
    required this.price,
    required this.period,
    required this.yearlyEquivalent,
    required this.isPopular,
  });
}

class _PlanCard extends StatelessWidget {
  final PlanOption plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: selected
              ? (isDarkMode ? Colors.white : Colors.white)
              : (isDarkMode ? Colors.white10 : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.blueAccent
                : (isDarkMode ? Colors.white24 : Colors.grey[300]!),
            width: 2.5,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plan.isPopular)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (plan.isPopular) const SizedBox(height: 8),
                  Text(
                    plan.title,
                    style: TextStyle(
                      color: selected
                          ? Colors.blue[900]
                          : (isDarkMode ? Colors.white : Colors.blue[900]),
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan.yearlyEquivalent,
                    style: TextStyle(
                      color: selected
                          ? Colors.blueGrey[700]
                          : (isDarkMode
                              ? Colors.white70
                              : Colors.blueGrey[700]),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plan.price} / ${plan.period}',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (selected)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.blueAccent,
                      size: 28,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
