import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/themes/app_colors.dart';

class SubsUpsellScreen extends ConsumerWidget {
  const SubsUpsellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.primaryBlue.withOpacity(0.95) : Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64, // SafeArea + padding
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Features
                      _FeatureRow(
                        icon: Icons.favorite,
                        iconColor: Colors.purple,
                        title: 'Unlimited Hearts',
                        description: 'Learn and retry as much as you want',
                      ),
                      const SizedBox(height: 24),
                      _FeatureRow(
                        icon: Icons.fitness_center,
                        iconColor: Colors.deepPurple,
                        title: 'Personalized Practice',
                        description: 'to target your weak areas',
                      ),
                      const SizedBox(height: 24),
                      _FeatureRow(
                        icon: Icons.groups,
                        iconColor: Colors.blueAccent,
                        title: 'Access to Community',
                        description: 'join and learn together',
                      ),
                      const SizedBox(height: 24),
                      _FeatureRow(
                        icon: Icons.block,
                        iconColor: Colors.pinkAccent,
                        title: 'No ads',
                        description: 'Enjoy a distraction-free experience',
                      ),
                      const SizedBox(height: 40),
                      // Larger logo image
                      SizedBox(
                        height: 120,
                        child: Image.asset(
                          'assets/images/logo/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Mission statement
                      Text(
                        'Support our mission to keep\neducation free for millions',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode ? Colors.white : AppColors.primaryBlue,
                        ),
                      ),
                      const Spacer(),
                      // Upgrade button
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
                          onPressed: () {
                            GoRouter.of(context).push('/subscription');
                          },
                          child: const Text('UPGRADE TO PRO'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'NO THANKS',
                          style: textTheme.labelLarge?.copyWith(
                            color: isDarkMode
                                ? Colors.white70
                                : AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.13),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryBlue,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
