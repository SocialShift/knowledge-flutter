import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/profile_provider.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditProfileScreen extends HookConsumerWidget {
  const EditProfileScreen({super.key});

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
    final profileAsync = ref.watch(userProfileProvider);
    final profileNotifier = ref.watch(profileNotifierProvider.notifier);
    final isLoading = useState(false);

    // Controllers and state variables
    final nicknameController = useTextEditingController();
    final selectedPronouns = useState<String>('');
    final selectedState = useState<String>('');
    final selectedLanguage = useState<String>('English');

    // Initialize controllers with current profile data
    useEffect(() {
      profileAsync.whenData((profile) {
        nicknameController.text = profile.nickname ?? '';
        selectedPronouns.value = profile.pronouns ?? '';
        selectedState.value = profile.location ?? '';
        selectedLanguage.value = profile.languagePreference ?? 'English';
      });
      return null;
    }, [profileAsync]);

    Future<void> handleSave() async {
      if (nicknameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a nickname'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      isLoading.value = true;
      try {
        await profileNotifier.updateProfile(
          nickname: nicknameController.text,
          pronouns: selectedPronouns.value,
          email: profileAsync.value?.email ?? '',
          location: selectedState.value,
          languagePreference: selectedLanguage.value,
        );

        if (context.mounted) {
          context.pop();
          // Refresh profile data
          ref.refresh(userProfileProvider);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
          ),
        ),
        error: (error, stack) => Center(
          child: SelectableText.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Error: ',
                  style: TextStyle(color: Colors.red),
                ),
                TextSpan(
                  text: error.toString(),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        data: (profile) => Stack(
          children: [
            // Background gradient for the entire screen
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.lightPurple,
                    AppColors.navyBlue,
                  ],
                  stops: [0.0, 0.3],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Avatar section
                  SizedBox(
                    height: 140,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          // Future functionality to change avatar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Avatar change coming soon!'),
                              backgroundColor: AppColors.navyBlue,
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'profileAvatar',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.limeGreen,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                const UserAvatar(size: 100),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn().scale(
                            delay: const Duration(milliseconds: 200),
                            duration: const Duration(milliseconds: 500),
                          ),
                    ),
                  ),
                  // Form fields - Expanded to fill remaining space
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
                        child: Column(
                          children: [
                            // Nickname field
                            _buildInfoTile(
                              context: context,
                              icon: Icons.person_outline,
                              title: 'Nickname',
                              controller: nicknameController,
                            ).animate().fadeIn().slideX(
                                  begin: -0.2,
                                  delay: const Duration(milliseconds: 300),
                                  duration: const Duration(milliseconds: 500),
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
                            ).animate().fadeIn().slideX(
                                  begin: -0.2,
                                  delay: const Duration(milliseconds: 400),
                                  duration: const Duration(milliseconds: 500),
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
                            ).animate().fadeIn().slideX(
                                  begin: -0.2,
                                  delay: const Duration(milliseconds: 500),
                                  duration: const Duration(milliseconds: 500),
                                ),
                            const SizedBox(height: 16),
                            // Language dropdown
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
                            ).animate().fadeIn().slideX(
                                  begin: -0.2,
                                  delay: const Duration(milliseconds: 600),
                                  duration: const Duration(milliseconds: 500),
                                ),
                            const SizedBox(height: 40),
                            // Save button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.limeGreen,
                                  foregroundColor: AppColors.navyBlue,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: isLoading.value ? null : handleSave,
                                child: isLoading.value
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppColors.navyBlue,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Save Changes',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.check_circle_outline,
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
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.limeGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.navyBlue,
          ),
        ),
        title: TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            color: Colors.grey[800],
          ),
          decoration: InputDecoration(
            hintText: 'Enter $title',
            hintStyle: TextStyle(
              color: Colors.grey[600],
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.limeGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.navyBlue,
          ),
        ),
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(
              'Select $title',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
            ),
            dropdownColor: Colors.white,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
