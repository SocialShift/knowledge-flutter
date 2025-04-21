import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/profile_provider.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/data/models/profile.dart';
import 'package:knowledge/data/providers/subscription_provider.dart';
import 'package:knowledge/data/providers/feedback_provider.dart';
import 'package:knowledge/presentation/screens/profile/delete_account_screen.dart';
import 'package:knowledge/presentation/widgets/feedback_dialog.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Confirm Logout',
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  Future<void> _showFeedbackDialog(BuildContext context, WidgetRef ref,
      {bool forceShow = false}) async {
    // Use the feedback provider to check if feedback has been shown before
    final feedbackState = await ref.read(feedbackNotifierProvider.future);

    // If feedback has already been shown and not forcing display, don't show again
    // When button is clicked explicitly (forceShow=true), show regardless of previous submissions
    if (feedbackState && !forceShow && context.mounted) return;

    // Mark feedback as shown using the notifier (if not already shown)
    if (!feedbackState) {
      ref.read(feedbackNotifierProvider.notifier).markFeedbackAsShown();
    }

    if (context.mounted) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const FeedbackDialog(),
      );

      if (result == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thank you for your feedback!'),
            backgroundColor: AppColors.limeGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final authNotifier = ref.watch(authNotifierProvider.notifier);

    // Hook to check if we need to show feedback dialog on first visit
    useEffect(() {
      // Check on app launch if feedback should be shown
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFeedbackDialog(context, ref, forceShow: false);
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.feedback_outlined,
            color: AppColors.navyBlue,
          ),
          onPressed: () => _showFeedbackDialog(context, ref, forceShow: true),
          tooltip: 'Give Feedback',
        ),
        actions: [
          // Pro Button
          TextButton.icon(
            onPressed: () => context.push('/subscription'),
            icon: const Icon(
              Icons.workspace_premium,
              color: AppColors.limeGreen,
              size: 20,
            ),
            label: const Text(
              'PRO',
              style: TextStyle(
                color: AppColors.limeGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.navyBlue.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.navyBlue),
            onPressed: () => context.push('/profile/edit'),
            tooltip: 'Edit Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              SelectableText.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Error loading profile: ',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: error.toString(),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.limeGreen,
                  foregroundColor: AppColors.navyBlue,
                ),
                onPressed: () => ref.refresh(userProfileProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) => SafeArea(
          child: RefreshIndicator(
            color: AppColors.limeGreen,
            onRefresh: () => ref.refresh(userProfileProvider.future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    // Profile Header
                    _buildProfileHeader(context, profile, ref),

                    const SizedBox(height: 24),

                    // Personal Info Section
                    _buildInfoSection(
                      context,
                      title: 'Personal Information',
                      icon: Icons.person,
                      items: [
                        InfoItem(
                          label: 'Nickname',
                          value: profile.nickname ?? 'Not set',
                          icon: Icons.person_outline,
                        ),
                        InfoItem(
                          label: 'Email',
                          value: profile.email,
                          icon: Icons.email_outlined,
                        ),
                        InfoItem(
                          label: 'Pronouns',
                          value: profile.pronouns ?? 'Not set',
                          icon: Icons.person_pin_outlined,
                        ),
                      ],
                    ).animate().fadeIn().slideY(
                          begin: 0.1,
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 300),
                        ),

                    const SizedBox(height: 16),

                    // Preferences Section
                    _buildInfoSection(
                      context,
                      title: 'Preferences',
                      icon: Icons.settings,
                      items: [
                        InfoItem(
                          label: 'Location',
                          value: profile.location ?? 'Not set',
                          icon: Icons.location_on_outlined,
                        ),
                        InfoItem(
                          label: 'Language',
                          value: profile.languagePreference ?? 'English',
                          icon: Icons.language_outlined,
                        ),
                      ],
                    ).animate().fadeIn().slideY(
                          begin: 0.1,
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 300),
                        ),

                    // Logout Button Section - only keep this one button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side:
                                const BorderSide(color: Colors.red, width: 1.5),
                            foregroundColor: Colors.red,
                            backgroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            final shouldLogout =
                                await _showLogoutConfirmationDialog(context);
                            if (shouldLogout && context.mounted) {
                              try {
                                await authNotifier.logout();
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error logging out: $e'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.all(12),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn().slideY(
                          begin: 0.1,
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 300),
                        ),

                    // Delete Account Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            backgroundColor: Colors.grey.shade100,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DeleteAccountScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text(
                            'Delete Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn().slideY(
                          begin: 0.1,
                          delay: const Duration(milliseconds: 450),
                          duration: const Duration(milliseconds: 300),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, Profile profile, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // Avatar with border
          Hero(
            tag: 'profileAvatar',
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.limeGreen, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: UserAvatar(size: 110),
                ),

                // PRO badge if subscribed
                if (subscriptionState.isSubscribed)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.limeGreen,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: AppColors.navyBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ).animate().fadeIn().scale(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 300),
              ),

          const SizedBox(height: 16),

          // Name and Email
          Column(
            children: [
              Text(
                profile.nickname ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ).animate().fadeIn(),

              // Show subscription status if subscribed
              if (subscriptionState.isSubscribed) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      size: 14,
                      color: AppColors.limeGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${subscriptionState.currentPlan.name.toUpperCase()} Plan',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.limeGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<InfoItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.navyBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Info items
              ...items.map((item) => _buildInfoItem(context, item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, InfoItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.limeGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: AppColors.navyBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoItem {
  final String label;
  final String value;
  final IconData icon;

  const InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}
