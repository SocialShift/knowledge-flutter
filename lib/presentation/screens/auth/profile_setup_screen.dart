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
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: const Color(0xFF1A1A1A),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade700,
                      const Color(0xFF1A1A1A),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: handleImageSelection,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue.shade400,
                            child: avatarFile.value != null
                                ? ClipOval(
                                    child: Image.file(
                                      File(avatarFile.value!.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Complete Your Profile',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Nickname field
                  _buildInfoTile(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Nickname',
                    controller: nicknameController,
                  ),
                  const SizedBox(height: 16),

                  // Pronouns dropdown
                  _buildDropdownTile(
                    context: context,
                    icon: Icons.person_pin_outlined,
                    title: 'Pronouns',
                    value: selectedPronouns.value.isEmpty
                        ? null
                        : selectedPronouns.value,
                    items: pronounOptions,
                    onChanged: (value) {
                      if (value != null) {
                        selectedPronouns.value = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field (disabled)
                  _buildInfoTile(
                    context: context,
                    icon: Icons.email_outlined,
                    title: 'Email',
                    controller: emailController,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),

                  // Location dropdown
                  _buildDropdownTile(
                    context: context,
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    value: selectedState.value.isEmpty
                        ? null
                        : selectedState.value,
                    items: states,
                    onChanged: (value) {
                      if (value != null) {
                        selectedState.value = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Language preference dropdown
                  _buildDropdownTile(
                    context: context,
                    icon: Icons.language_outlined,
                    title: 'Language',
                    value: selectedLanguage.value,
                    items: languages,
                    onChanged: (value) {
                      if (value != null) {
                        selectedLanguage.value = value;
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading.value ? null : handleSave,
                      child: isLoading.value
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: TextField(
          controller: controller,
          enabled: enabled,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter your $title',
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Theme(
          data: Theme.of(context).copyWith(
            dropdownMenuTheme: DropdownMenuThemeData(
              textStyle: const TextStyle(color: Colors.white),
            ),
          ),
          child: DropdownButton<String>(
            value: value,
            hint: Text('Select $title',
                style: TextStyle(color: Colors.grey[400])),
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: Colors.grey[900],
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
