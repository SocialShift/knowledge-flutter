import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/profile_provider.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:knowledge/presentation/screens/profile/avatar_selection_screen.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

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
    // Get theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.grey[50];
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final dividerColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final borderColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
    final fieldColor = isDarkMode ? AppColors.darkSurface : Colors.white;

    final profileAsync = ref.watch(userProfileProvider);
    final profileNotifier = ref.watch(profileNotifierProvider.notifier);
    final isLoading = useState(false);

    // Controllers and state variables
    final nicknameController = useTextEditingController();
    final emailController = useTextEditingController();
    final selectedPronouns = useState<String>('');
    final selectedState = useState<String>('');
    final selectedLanguage = useState<String>('English');
    final selectedImage = useState<File?>(null);
    final selectedGameAvatar = useState<String?>(null);

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

    Future<void> pickFromDevice() async {
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          selectedImage.value = File(pickedFile.path);
          selectedGameAvatar.value = null; // Clear game avatar selection
          // Show a snackbar confirmation
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Image selected successfully'),
                backgroundColor:
                    isDarkMode ? AppColors.darkCard : AppColors.navyBlue,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(12),
              ),
            );
          }
        }
      } catch (e) {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error selecting image: $e'),
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

    Future<void> pickGameAvatar() async {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const AvatarSelectionScreen(),
        ),
      );

      if (result != null) {
        selectedGameAvatar.value = result;
        selectedImage.value = null; // Clear device image selection
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Game avatar selected successfully'),
              backgroundColor:
                  isDarkMode ? AppColors.darkCard : AppColors.navyBlue,
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

    void showAvatarOptions() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choose Avatar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    Icons.pets,
                    color:
                        isDarkMode ? AppColors.limeGreen : AppColors.navyBlue,
                  ),
                  title: Text(
                    'Game Avatars',
                    style: TextStyle(color: textColor),
                  ),
                  subtitle: const Text('Choose from our collection'),
                  onTap: () {
                    Navigator.pop(context);
                    pickGameAvatar();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color:
                        isDarkMode ? AppColors.limeGreen : AppColors.navyBlue,
                  ),
                  title: Text(
                    'Device Gallery',
                    style: TextStyle(color: textColor),
                  ),
                  subtitle: const Text('Pick from your photos'),
                  onTap: () {
                    Navigator.pop(context);
                    pickFromDevice();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }

    Future<void> handleSave() async {
      if (nicknameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a nickname'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
        return;
      }

      isLoading.value = true;
      try {
        String? imageUrl;
        if (selectedImage.value != null) {
          imageUrl = "file://${selectedImage.value!.path}";
        } else if (selectedGameAvatar.value != null) {
          imageUrl = selectedGameAvatar.value;
        }

        await profileNotifier.updateProfile(
          nickname: nicknameController.text,
          pronouns: selectedPronouns.value,
          email: profileAsync.value?.email ?? '',
          location: selectedState.value,
          languagePreference: selectedLanguage.value,
          avatarUrl: imageUrl,
        );

        if (context.mounted) {
          context.pop();
          // Refresh profile data
          ref.invalidate(userProfileProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(12),
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          // Save button in the app bar (primary save location)
          TextButton.icon(
            onPressed: isLoading.value ? null : () => handleSave(),
            icon: isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.limeGreen)),
                  )
                : const Icon(Icons.check, color: AppColors.limeGreen),
            label: Text(
              'Save',
              style: TextStyle(
                color: isLoading.value ? Colors.grey : AppColors.limeGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          child: SelectableText.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Error: ',
                  style: TextStyle(color: Colors.red),
                ),
                TextSpan(
                  text: error.toString(),
                  style: TextStyle(color: secondaryTextColor),
                ),
              ],
            ),
          ),
        ),
        data: (profile) => SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // Profile Photo Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: showAvatarOptions,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.limeGreen, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Hero(
                                  tag: 'profileAvatar',
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor: isDarkMode
                                        ? AppColors.darkCard
                                        : Colors.white,
                                    child: ClipOval(
                                      child: selectedImage.value != null
                                          ? Image.file(
                                              selectedImage.value!,
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit.cover,
                                            )
                                          : selectedGameAvatar.value != null
                                              ? Image.asset(
                                                  selectedGameAvatar.value!,
                                                  width: 110,
                                                  height: 110,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return UserAvatar(
                                                        size: 110);
                                                  },
                                                )
                                              : UserAvatar(
                                                  size: 110,
                                                ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.limeGreen,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().scale(
                              delay: const Duration(milliseconds: 100),
                              duration: const Duration(milliseconds: 400),
                            ),
                        const SizedBox(height: 12),
                        // Tap to change photo hint
                        Text(
                          'Tap to change profile photo',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ).animate().fadeIn(),
                      ],
                    ),
                  ),

                  // Basic Info Section
                  _buildSectionCard(
                    context,
                    title: 'Basic Information',
                    icon: Icons.person,
                    children: [
                      _buildInfoField(
                        context,
                        'Nickname',
                        nicknameController,
                        Icons.person_outline,
                        required: true,
                        isDarkMode: isDarkMode,
                        fieldColor: fieldColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      const SizedBox(height: 16),
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
                        required: true,
                        isDarkMode: isDarkMode,
                        fieldColor: fieldColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        context,
                        'Email',
                        emailController,
                        Icons.email_outlined,
                        enabled: false,
                        helperText: 'Your email cannot be changed',
                        isDarkMode: isDarkMode,
                        fieldColor: isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        borderColor: borderColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ],
                    isDarkMode: isDarkMode,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    dividerColor: dividerColor,
                  ).animate().fadeIn().slideY(
                        begin: 0.1,
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 400),
                      ),

                  const SizedBox(height: 16),

                  // Location & Preferences Section
                  _buildSectionCard(
                    context,
                    title: 'Location & Preferences',
                    icon: Icons.settings,
                    children: [
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
                        isDarkMode: isDarkMode,
                        fieldColor: fieldColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      const SizedBox(height: 16),
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
                        isDarkMode: isDarkMode,
                        fieldColor: fieldColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ],
                    isDarkMode: isDarkMode,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    dividerColor: dividerColor,
                  ).animate().fadeIn().slideY(
                        begin: 0.1,
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 400),
                      ),

                  // Additional bottom padding to ensure content is visible
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDarkMode,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color dividerColor,
  }) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              children: [
                Icon(
                  icon,
                  color: textColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: dividerColor),
            ...children,
          ],
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
    bool required = false,
    String? helperText,
    required bool isDarkMode,
    required Color fieldColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: secondaryTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            color: enabled ? textColor : secondaryTextColor,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your $label',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
            helperText: helperText,
            helperStyle: TextStyle(
              color: secondaryTextColor,
              fontSize: 12,
            ),
            prefixIcon: Icon(
              icon,
              color: enabled
                  ? (isDarkMode ? AppColors.limeGreen : AppColors.navyBlue)
                  : Colors.grey,
              size: 20,
            ),
            filled: true,
            fillColor: enabled
                ? fieldColor
                : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.limeGreen,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
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
    List<String> options,
    IconData icon,
    Function(String?)? onChanged, {
    bool required = false,
    required bool isDarkMode,
    required Color fieldColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: secondaryTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          icon: Icon(Icons.arrow_drop_down,
              color: isDarkMode ? AppColors.limeGreen : AppColors.navyBlue),
          dropdownColor: isDarkMode ? AppColors.darkSurface : Colors.white,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: isDarkMode ? AppColors.limeGreen : AppColors.navyBlue,
              size: 20,
            ),
            filled: true,
            fillColor: fieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.limeGreen,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          hint: Text(
            'Select your $label',
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
          isExpanded: true,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: textColor),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
