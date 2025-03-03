import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:knowledge/data/providers/profile_provider.dart';
// import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:knowledge/data/providers/onboarding_provider.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileSetupScreen extends HookConsumerWidget {
  const ProfileSetupScreen({super.key});

  static const List<String> pronounOptions = [
    'He/Him',
    'She/Her',
    'They/Them',
    'Other'
  ];

  static const List<String> states = [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming'
  ];

  static const List<String> languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final profileNotifier = ref.watch(profileNotifierProvider.notifier);
    final onboardingState = ref.watch(onboardingNotifierProvider);

    // Get user email from auth state
    final userEmail = authState.maybeMap(
      authenticated: (state) => state.user.email,
      orElse: () => '',
    );

    // Controllers and state variables
    final nicknameController = useTextEditingController();
    final emailController = useTextEditingController(text: userEmail);
    final isLoading = useState(false);
    final selectedPronouns = useState<String>('');
    final selectedState = useState<String>('');
    final selectedLanguage = useState<String>('English');
    final avatarFile = useState<XFile?>(null);

    // Handle image selection
    Future<void> handleImageSelection() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        avatarFile.value = image;
      }
    }

    // Handle profile update
    Future<void> handleSave() async {
      if (nicknameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a nickname')),
        );
        return;
      }

      isLoading.value = true;
      try {
        // Get all responses from onboarding
        final Map<String, dynamic> personalizationQuestions = {
          ...onboardingState.responses,
          'race': onboardingState.race,
          'gender': onboardingState.gender,
          'ethnicity': onboardingState.ethnicity,
          'topics': onboardingState.selectedTopics,
          'interests': onboardingState.selectedInterests,
          'discovery_source': onboardingState.discoverySource,
          'primary_interest': onboardingState.primaryInterest,
        };

        await profileNotifier.updateProfile(
          nickname: nicknameController.text,
          pronouns: selectedPronouns.value,
          email: emailController.text,
          location: selectedState.value,
          languagePreference: selectedLanguage.value,
          personalizationQuestions: personalizationQuestions,
        );

        if (context.mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3949AB), // Slightly lighter navy blue
              AppColors.navyBlue,
            ],
            stops: [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header with avatar
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: handleImageSelection,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.limeGreen,
                              child: avatarFile.value != null
                                  ? ClipOval(
                                      child: Image.file(
                                        File(avatarFile.value!.path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppColors.navyBlue,
                                    ),
                            ),
                          ),
                        ).animate().fadeIn().scale(
                              duration: const Duration(milliseconds: 500),
                            ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.limeGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: AppColors.navyBlue,
                            ),
                          ),
                        ).animate().fadeIn(
                              delay: const Duration(milliseconds: 300),
                            ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Complete Your Profile',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideY(
                          begin: 0.3,
                          duration: const Duration(milliseconds: 500),
                        ),
                  ],
                ),
              ),

              // Profile Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nickname field
                            _buildInfoField(
                              context,
                              'Nickname',
                              nicknameController,
                              Icons.person_outline,
                            ).animate().fadeIn().slideX(
                                  begin: -0.2,
                                  delay: const Duration(milliseconds: 200),
                                  duration: const Duration(milliseconds: 500),
                                ),
                            const SizedBox(height: 16),

                            // Pronouns dropdown
                            _buildDropdownField(
                              context,
                              'Pronouns',
                              selectedPronouns.value.isEmpty
                                  ? null
                                  : selectedPronouns.value,
                              pronounOptions,
                              Icons.person_pin_outlined,
                              (value) {
                                if (value != null) {
                                  selectedPronouns.value = value;
                                }
                              },
                            ).animate().fadeIn().slideX(
                                  begin: -0.2,
                                  delay: const Duration(milliseconds: 300),
                                  duration: const Duration(milliseconds: 500),
                                ),
                            const SizedBox(height: 16),

                            // Email field (disabled)
                            _buildInfoField(
                              context,
                              'Email',
                              emailController,
                              Icons.email_outlined,
                              enabled: false,
                            ).animate().fadeIn().slideX(
                                  begin: -0.2,
                                  delay: const Duration(milliseconds: 400),
                                  duration: const Duration(milliseconds: 500),
                                ),
                            const SizedBox(height: 16),

                            // Location dropdown
                            _buildDropdownField(
                              context,
                              'Location',
                              selectedState.value.isEmpty
                                  ? null
                                  : selectedState.value,
                              states,
                              Icons.location_on_outlined,
                              (value) {
                                if (value != null) {
                                  selectedState.value = value;
                                }
                              },
                            ).animate().fadeIn().slideX(
                                  begin: -0.2,
                                  delay: const Duration(milliseconds: 500),
                                  duration: const Duration(milliseconds: 500),
                                ),
                            const SizedBox(height: 16),

                            // Language preference dropdown
                            _buildDropdownField(
                              context,
                              'Language',
                              selectedLanguage.value,
                              languages,
                              Icons.language_outlined,
                              (value) {
                                if (value != null) {
                                  selectedLanguage.value = value;
                                }
                              },
                            ).animate().fadeIn().slideX(
                                  begin: -0.2,
                                  delay: const Duration(milliseconds: 600),
                                  duration: const Duration(milliseconds: 500),
                                ),
                            const SizedBox(height: 32),

                            // Save button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.limeGreen,
                                  foregroundColor: AppColors.navyBlue,
                                  elevation: 2,
                                  shadowColor:
                                      AppColors.limeGreen.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isLoading.value ? null : handleSave,
                                child: isLoading.value
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.navyBlue),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Save Profile',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: AppColors.navyBlue,
                                          ),
                                        ],
                                      ),
                              ),
                            ).animate().fadeIn().slideY(
                                  begin: 0.2,
                                  delay: const Duration(milliseconds: 700),
                                  duration: const Duration(milliseconds: 500),
                                ),
                            // Add extra space at the bottom to ensure white background extends
                            SizedBox(
                                height:
                                    MediaQuery.of(context).padding.bottom + 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your $label',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.navyBlue,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    BuildContext context,
    String label,
    String? value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              'Select $label',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AppColors.navyBlue,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
            dropdownColor: Colors.white,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
