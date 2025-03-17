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
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final profileNotifier = ref.watch(profileNotifierProvider.notifier);
    final isLoading = useState(false);

    // Controllers and state variables
    final nicknameController = useTextEditingController();
    final emailController = useTextEditingController();
    final selectedPronouns = useState<String>('');
    final selectedState = useState<String>('');
    final selectedLanguage = useState<String>('English');

    // Initialize controllers with current profile data
    useEffect(() {
      profileAsync.whenData((profile) {
        nicknameController.text = profile.nickname ?? '';
        emailController.text = profile.email;
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
        data: (profile) => Container(
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
                      GestureDetector(
                        onTap: () {
                          // Future functionality to change avatar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Avatar change coming soon!'),
                              backgroundColor: AppColors.navyBlue,
                            ),
                          );
                        },
                        child: Stack(
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
                              child: Hero(
                                tag: 'profileAvatar',
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.limeGreen,
                                  child: const ClipOval(
                                    child: UserAvatar(size: 100),
                                  ),
                                ),
                              ),
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
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(
                            delay: const Duration(milliseconds: 200),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 16),
                      Text(
                        'Edit Your Profile',
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
                                  onPressed:
                                      isLoading.value ? null : handleSave,
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
                              // Add extra space at the bottom to ensure white background extends
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                          20),
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
