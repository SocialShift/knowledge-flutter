import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/onboarding_provider.dart';
import 'package:knowledge/data/models/onboarding_state.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.lime[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              LinearProgressIndicator(
                value: (onboardingState.currentStep + 1) / 4,
                backgroundColor: Colors.blue.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 40),
              if (onboardingState.currentStep == 0)
                _buildIdentitySection(context, onboardingState, notifier)
              else if (onboardingState.currentStep == 1)
                _buildTopicsSection(context, onboardingState, notifier)
              else if (onboardingState.currentStep == 2)
                _buildDiscoverySection(context, onboardingState, notifier)
              else
                _buildInterestsSection(context, onboardingState, notifier),
              const Spacer(),
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
          'How do you identify yourself?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 32),
        _buildSelectionGroup(
          context: context,
          title: 'Race',
          options: ['Asian', 'Black', 'White', 'Mixed', 'Other'],
          selected: state.race,
          onSelected: notifier.updateRace,
        ),
        const SizedBox(height: 24),
        _buildSelectionGroup(
          context: context,
          title: 'Gender',
          options: ['Male', 'Female', 'Non-binary', 'Other'],
          selected: state.gender,
          onSelected: notifier.updateGender,
        ),
        const SizedBox(height: 24),
        _buildSelectionGroup(
          context: context,
          title: 'Ethnicity',
          options: ['Hispanic', 'Non-Hispanic', 'Other'],
          selected: state.ethnicity,
          onSelected: notifier.updateEthnicity,
        ),
      ],
    );
  }

  Widget _buildTopicsSection(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final topics = [
      'Ancient History',
      'Women\'s Rights',
      'Civil Rights',
      'Cultural Studies',
      'Gender Studies',
      'World Wars',
      'Renaissance',
      'Industrial Revolution',
      'Social Movements',
      'Religious History',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Help us personalize your experience',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 16),
        Text(
          'Select topics that interest you',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black54,
              ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: topics.map((topic) {
            final isSelected = state.selectedTopics.contains(topic);
            return AnimatedScale(
              scale: isSelected ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => notifier.toggleTopic(topic),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    topic,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
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

  Widget _buildDiscoverySection(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final sources = [
      'Social Media',
      'Friend/Family',
      'Search Engine',
      'Advertisement',
      'Educational Institution',
      'Other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did you discover our platform?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 32),
        ...sources
            .map((source) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedScale(
                    scale: state.discoverySource == source ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () => notifier.updateDiscoverySource(source),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: state.discoverySource == source
                              ? Colors.blue
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: state.discoverySource == source
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          source,
                          style: TextStyle(
                            color: state.discoverySource == source
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: state.discoverySource == source
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildInterestsSection(
    BuildContext context,
    OnboardingState state,
    OnboardingNotifier notifier,
  ) {
    final interests = [
      'Social Justice Movements',
      'Women\'s History',
      'Indigenous Cultures',
      'LGBTQ+ Narratives',
      'Civil Rights',
      'Cultural Revolution',
      'Political History',
      'Art History',
      'Military History',
      'Economic History',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which history topics interest you the most?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 16),
        Text(
          'Select all that apply',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black54,
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
                    color:
                        isSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
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
                    color:
                        isSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
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
    final isLastStep = state.currentStep == 3;
    final canProceed = state.currentStep < 2 ||
        (state.currentStep == 2 && state.discoverySource.isNotEmpty) ||
        (state.currentStep == 3 && state.selectedInterests.isNotEmpty);

    return Row(
      children: [
        if (state.currentStep < 2)
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
              style: TextStyle(color: Colors.blue[700]),
            ),
          ),
        const Spacer(),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
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
    ).animate().fadeIn(delay: const Duration(milliseconds: 400));
  }
}
