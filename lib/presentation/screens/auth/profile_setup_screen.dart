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

    // Get username from auth state if available (using username instead of nickname)
    final userUsername = authState.maybeMap(
      authenticated: (state) => state.user.username,
      orElse: () => '',
    );

    // Controllers and state variables
    final nicknameController = useTextEditingController(text: userUsername);
    final emailController = useTextEditingController(text: userEmail);
    final isLoading = useState(false);
    final selectedPronouns = useState<String>('');
    final selectedState = useState<String>('');
    final selectedLanguage = useState<String>('English');
    final avatarFile = useState<XFile?>(null);

    // Function to check if all required fields are filled
    final isFormValid = useState(false);

    // Function to validate the form
    void _validateForm() {
      final isValid = nicknameController.text.isNotEmpty &&
          selectedPronouns.value.isNotEmpty &&
          selectedState.value.isNotEmpty;
      isFormValid.value = isValid;
    }

    // Initialize form validation
    useEffect(() {
      // Initial validation
      _validateForm();

      return null;
    }, []);

    // Update form validity whenever any field changes
    useEffect(() {
      void listener() => _validateForm();

      // Add listeners to controller
      nicknameController.addListener(listener);

      // Initial check
      _validateForm();

      return () {
        nicknameController.removeListener(listener);
      };
    }, [nicknameController, selectedPronouns.value, selectedState.value]);

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
      if (!isFormValid.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
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
          avatarUrl: avatarFile.value?.path,
        );

        if (context.mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Complete Your Profile',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Required fields indicator
                        Tooltip(
                          message: 'All fields are required except avatar',
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.white.withOpacity(0.8),
                            size: 18,
                          ),
                        ),
                      ],
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
                            _buildInfoField(
                              title: 'Nickname',
                              subtitle: 'This is how you\'ll appear to others',
                              controller: nicknameController,
                              onChanged: (_) {},
                              isRequired: true,
                            ),
                            _buildInfoField(
                              title: 'Email',
                              subtitle:
                                  'Used for account recovery and notifications',
                              controller: emailController,
                              onChanged: (_) {},
                              isEmail: true,
                              isRequired: false,
                            ),
                            _buildDropdownField(
                              title: 'Pronouns',
                              subtitle: 'How would you like to be addressed?',
                              value: selectedPronouns.value,
                              items: const [
                                'He/Him',
                                'She/Her',
                                'They/Them',
                                'Prefer not to say',
                              ],
                              onChanged: (value) =>
                                  selectedPronouns.value = value,
                              isRequired: true,
                            ),
                            _buildDropdownField(
                              title: 'Location',
                              subtitle: 'Which state do you live in?',
                              value: selectedState.value,
                              items: states,
                              onChanged: (value) => selectedState.value = value,
                              isRequired: true,
                            ),
                            _buildDropdownField(
                              title: 'Language Preference',
                              subtitle:
                                  'Which language do you prefer for content?',
                              value: selectedLanguage.value,
                              items: const ['English', 'Spanish', 'French'],
                              onChanged: (value) =>
                                  selectedLanguage.value = value,
                              isRequired: false,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFormValid.value
                                      ? AppColors.limeGreen
                                      : Colors.grey.shade400,
                                  foregroundColor: AppColors.navyBlue,
                                  elevation: isFormValid.value ? 2 : 0,
                                  shadowColor: isFormValid.value
                                      ? AppColors.limeGreen.withOpacity(0.5)
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isLoading.value || !isFormValid.value
                                    ? null
                                    : handleSave,
                                child: isLoading.value
                                    ? const SizedBox(
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
                                          const Text(
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
                            ),
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

  Widget _buildInfoField({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required Function(String) onChanged,
    bool isEmail = false,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            onChanged: onChanged,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    bool isRequired = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
