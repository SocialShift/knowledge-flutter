import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/onboarding_provider.dart';
import 'package:knowledge/data/models/onboarding_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: (onboardingState.currentStep + 1) / 3,
                backgroundColor: AppColors.lightGray,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (onboardingState.currentStep == 0)
                        _buildIdentitySection(
                            context, onboardingState, notifier)
                      else if (onboardingState.currentStep == 1)
                        _buildDiscoverySection(
                            context, onboardingState, notifier)
                      else
                        _buildInterestsSection(
                            context, onboardingState, notifier),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(context, onboardingState, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentitySection(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How do you self-identify?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 12),
        Text(
          'This helps us understand your background and ensure we tailor content to your interests and needs.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),
        _buildSelectionGroup(
          context: context,
          title: '1. Race/Ethnicity',
          options: [
            'African/African Diaspora',
            'Asian/Asian Diaspora',
            'Indigenous/Native',
            'Latino/Hispanic',
            'Middle Eastern/North African',
            'Pacific Islander',
            'White/European',
            'Multiracial/Mixed Heritage',
            'Other',
            'Prefer not to say',
          ],
          selected: state.race,
          onSelected: notifier.updateRace,
        ),
        const SizedBox(height: 24),
        _buildSelectionGroup(
          context: context,
          title: '2. Gender Identity',
          options: [
            'Woman',
            'Man',
            'Non-Binary',
            'Genderqueer/Gender Non-Conforming',
            'Transgender',
            'Two-Spirit (Indigenous-specific identity)',
            'Other',
            'Prefer not to say',
          ],
          selected: state.gender,
          onSelected: notifier.updateGender,
        ),
        const SizedBox(height: 24),
        _buildSelectionGroup(
          context: context,
          title: '3. Sexual Orientation',
          options: [
            'Heterosexual/Straight',
            'Gay/Lesbian',
            'Bisexual/Pansexual',
            'Asexual',
            'Queer',
            'Other',
            'Prefer not to say',
          ],
          selected: state.ethnicity,
          onSelected: notifier.updateEthnicity,
        ),
      ],
    );
  }

  Widget _buildDiscoverySection(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final sources = [
      'Social Media',
      'Word of Mouth',
      'Online Search',
      'Educational Institution',
      'News Article or Blog',
      'Other (please specify)',
    ];

    // Controller for the "Other" text field
    final otherController = TextEditingController();

    // Social media options for dropdown
    final socialMediaOptions = [
      'Instagram',
      'BlueSky',
      'LinkedIn',
      'Twitter/X',
      'Facebook',
      'TikTok',
      'Other'
    ];

    // Selected social media platform - get from state or default to first option
    String selectedSocialMedia = state.socialMediaPlatform.isEmpty
        ? socialMediaOptions.first
        : state.socialMediaPlatform;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did you discover our platform?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 32),
        ...sources.map((source) {
          final isSelected = state.discoverySource == source;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedScale(
                  scale: isSelected ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: () => notifier.updateDiscoverySource(source),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.limeGreen
                            : AppColors.lightPurple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.limeGreen.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        source,
                        style: TextStyle(
                          color:
                              isSelected ? AppColors.navyBlue : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Show text field if "Other" is selected
              if (isSelected && source == 'Other (please specify)')
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                  child: TextField(
                    controller: otherController,
                    decoration: InputDecoration(
                      hintText: 'Please specify how you discovered us',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.navyBlue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      // Store the value in the state if needed
                      // This would require adding a field to your state model
                    },
                  ).animate().fadeIn().slideY(
                        begin: 0.2,
                        duration: const Duration(milliseconds: 300),
                      ),
                ),
              // Show dropdown if "Social Media" is selected
              if (isSelected && source == 'Social Media')
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedSocialMedia,
                        items: socialMediaOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            // Update the selected social media in the state
                            notifier.updateSocialMediaPlatform(newValue);
                          }
                        },
                      ),
                    ),
                  ).animate().fadeIn().slideY(
                        begin: 0.2,
                        duration: const Duration(milliseconds: 300),
                      ),
                ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInterestsSection(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final interests = [
      'Indigenous Histories and Cultures',
      'African Diaspora and Black History',
      'LGBTQ+ Movements and Milestones',
      'Women\'s Histories and Contributions',
      'Immigrant and Refugee Stories',
      'Colonialism and Post-Colonial Histories',
      'Civil Rights and Social Justice Movements',
      'Lesser-Known Historical Figures',
      'Other (please specify)',
    ];

    // Controller for the "Other" text field
    final otherInterestController = TextEditingController();

    // Check if "Other" is selected
    final isOtherSelected =
        state.selectedInterests.contains('Other (please specify)');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which history topics interest you the most?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 16),
        Text(
          'Select all that apply',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: interests.map((interest) {
            final isSelected = state.selectedInterests.contains(interest);
            return AnimatedScale(
              scale: isSelected ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => notifier.toggleInterest(interest),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.limeGreen
                        : AppColors.lightPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.limeGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      color: isSelected ? AppColors.navyBlue : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Show text field if "Other" is selected
        if (isOtherSelected)
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 4, right: 4),
            child: TextField(
              controller: otherInterestController,
              decoration: InputDecoration(
                hintText: 'Please specify your other historical interests',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.navyBlue),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                // Store the value in the state if needed
                // This would require adding a field to your state model
              },
            ).animate().fadeIn().slideY(
                  begin: 0.2,
                  duration: const Duration(milliseconds: 300),
                ),
          ),
      ],
    );
  }

  Widget _buildSelectionGroup({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.navyBlue,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return AnimatedScale(
              scale: isSelected ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => onSelected(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.limeGreen
                        : AppColors.lightPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.limeGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? AppColors.navyBlue : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final isLastStep = state.currentStep == 2;
    final canProceed = state.currentStep < 1 ||
        (state.currentStep == 1 && state.discoverySource.isNotEmpty) ||
        (state.currentStep == 2 && state.selectedInterests.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          if (state.currentStep < 1)
            TextButton(
              onPressed: () {
                notifier.completeOnboarding();
                if (context.mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go('/home');
                  });
                }
              },
              child: Text(
                'Skip',
                style: TextStyle(color: AppColors.navyBlue),
              ),
            ),
          const Spacer(),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.limeGreen,
              foregroundColor: AppColors.navyBlue,
            ),
            onPressed: canProceed
                ? () {
                    if (!isLastStep) {
                      notifier.nextStep();
                    } else {
                      notifier.completeOnboarding();
                      if (context.mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.go('/home');
                        });
                      }
                    }
                  }
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isLastStep ? 'Get Started' : 'Next'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400));
  }
}
