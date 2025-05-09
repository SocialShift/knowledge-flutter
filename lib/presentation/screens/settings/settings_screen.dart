import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/presentation/screens/profile/delete_account_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final themeNotifier = ref.watch(themeModeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navyBlue),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Profile Settings Section
              _SettingsSection(
                title: 'Profile Settings',
                icon: Icons.person_outline,
                children: [
                  _SettingsTile(
                    title: 'Edit Profile',
                    leading: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.navyBlue,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _SettingsTile(
                    title: 'Delete Account',
                    leading: const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // Navigate to delete account screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DeleteAccountScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ).animate().fadeIn(delay: const Duration(milliseconds: 100)),

              const SizedBox(height: 16),

              // Appearance Section
              // _SettingsSection(
              //   title: 'Appearance',
              //   icon: Icons.color_lens_outlined,
              //   children: [
              //     _SettingsTile(
              //       title: 'Theme',
              //       leading: Icon(
              //         themeMode == ThemeMode.dark
              //             ? Icons.dark_mode_outlined
              //             : Icons.light_mode_outlined,
              //         color: AppColors.navyBlue,
              //       ),
              //       trailing: Switch(
              //         value: themeMode == ThemeMode.dark,
              //         onChanged: (_) => themeNotifier.toggleTheme(),
              //         activeColor: AppColors.limeGreen,
              //         activeTrackColor: AppColors.navyBlue.withOpacity(0.5),
              //       ),
              //       onTap: () => themeNotifier.toggleTheme(),
              //     ),
              //   ],
              // ).animate().fadeIn(delay: const Duration(milliseconds: 200)),

              const SizedBox(height: 16),

              // About App Section
              // _SettingsSection(
              //   title: 'About',
              //   icon: Icons.info_outline,
              //   children: [
              //     _SettingsTile(
              //       title: 'Version',
              //       leading: const Icon(
              //         Icons.app_settings_alt_outlined,
              //         color: AppColors.navyBlue,
              //       ),
              //       trailing: const Text(
              //         '1.0.0',
              //         style: TextStyle(
              //           color: Colors.grey,
              //           fontSize: 14,
              //         ),
              //       ),
              //       onTap: () {},
              //     ),
              //   ],
              // ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppColors.limeGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.navyBlue,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: theme.dividerColor),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final Widget leading;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.leading,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
