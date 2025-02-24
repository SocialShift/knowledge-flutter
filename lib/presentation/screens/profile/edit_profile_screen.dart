import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/profile_provider.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';

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
        selectedLanguage.value = profile.preferredLanguage;
      });
      return null;
    }, [profileAsync]);

    Future<void> handleSave() async {
      if (nicknameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a nickname')),
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
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error',
              style: const TextStyle(color: Colors.white)),
        ),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Center(
                child: UserAvatar(size: 100),
              ),
              const SizedBox(height: 32),
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
              // Location dropdown
              _buildDropdownTile(
                context: context,
                icon: Icons.location_on_outlined,
                title: 'Location',
                value: selectedState.value.isEmpty ? null : selectedState.value,
                items: states,
                onChanged: (value) {
                  if (value != null) {
                    selectedState.value = value;
                  }
                },
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
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
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
    required void Function(String?)? onChanged,
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
