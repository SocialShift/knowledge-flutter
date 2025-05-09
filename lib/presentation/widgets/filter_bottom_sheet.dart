import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/providers/filter_provider.dart';
// import 'package:flutter_animate/flutter_animate.dart';

class FilterBottomSheet extends HookConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterNotifierProvider);
    final notifier = ref.watch(filterNotifierProvider.notifier);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.navyBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Content',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (filterState.hasActiveFilters)
                      TextButton(
                        onPressed: () => notifier.clearFilters(),
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: AppColors.limeGreen),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Content
          Flexible(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRaceSection(context, filterState, notifier),
                    const Divider(height: 40),
                    _buildGenderSection(context, filterState, notifier),
                    const Divider(height: 40),
                    _buildSexualOrientationSection(
                        context, filterState, notifier),
                    const Divider(height: 40),
                    _buildInterestsSection(context, filterState, notifier),
                    const Divider(height: 40),
                    _buildCategoriesSection(context, filterState, notifier),
                  ],
                ),
              ),
            ),
          ),

          // Apply Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                filterState.hasActiveFilters
                    ? 'Apply Filters (${filterState.activeFilterCount})'
                    : 'Apply',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceSection(
      BuildContext context, FilterState state, FilterNotifier notifier) {
    final races = [
      'African/African Diaspora',
      'Asian/Asian Diaspora',
      'Indigenous/Native',
      'Latino/Hispanic',
      'Middle Eastern/North African',
      'Pacific Islander',
      'White/European',
      'Multiracial/Mixed Heritage',
      'Other',
    ];

    return _buildSelectionGroup(
      title: 'Race/Ethnicity',
      description: 'Filter content by historical and cultural relevance',
      options: races,
      selectedValue: state.race,
      onSelected: notifier.updateRace,
    );
  }

  Widget _buildGenderSection(
      BuildContext context, FilterState state, FilterNotifier notifier) {
    final genders = [
      'Woman',
      'Man',
      'Non-Binary',
      'Genderqueer/Gender Non-Conforming',
      'Transgender',
      'Two-Spirit (Indigenous-specific identity)',
      'Other',
    ];

    return _buildSelectionGroup(
      title: 'Gender Identity',
      description: 'Filter content related to gender perspectives',
      options: genders,
      selectedValue: state.gender,
      onSelected: notifier.updateGender,
    );
  }

  Widget _buildSexualOrientationSection(
      BuildContext context, FilterState state, FilterNotifier notifier) {
    final orientations = [
      'Heterosexual/Straight',
      'Gay/Lesbian',
      'Bisexual/Pansexual',
      'Asexual',
      'Queer',
      'Other',
    ];

    return _buildSelectionGroup(
      title: 'Sexual Orientation',
      description: 'Filter content related to LGBTQ+ history and perspectives',
      options: orientations,
      selectedValue: state.sexualOrientation,
      onSelected: notifier.updateSexualOrientation,
    );
  }

  Widget _buildInterestsSection(
      BuildContext context, FilterState state, FilterNotifier notifier) {
    final interests = [
      'Indigenous Histories and Cultures',
      'African Diaspora and Black History',
      'LGBTQ+ Movements and Milestones',
      'Women\'s Histories and Contributions',
      'Immigrant and Refugee Stories',
      'Colonialism and Post-Colonial Histories',
      'Civil Rights and Social Justice Movements',
      'Lesser-Known Historical Figures',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Topics of Interest',
          style: TextStyle(
            color: AppColors.navyBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select topics you want to see more of',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: interests.map((interest) {
            final isSelected = state.interests.contains(interest);
            return GestureDetector(
              onTap: () => notifier.toggleInterest(interest),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
                            blurRadius: 4,
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
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(
      BuildContext context, FilterState state, FilterNotifier notifier) {
    final categories = [
      'African/African Diaspora',
      'Civil Rights and Social Justice Movements',
      'Lesser-Known Historical Figures',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            color: AppColors.navyBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Filter content by category',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: categories.map((category) {
            final isSelected = state.categories.contains(category);
            return GestureDetector(
              onTap: () => notifier.toggleCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? AppColors.navyBlue : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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
    required String title,
    required String description,
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navyBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () => onSelected(option == selectedValue ? '' : option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
                            blurRadius: 4,
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
            );
          }).toList(),
        ),
      ],
    );
  }
}
