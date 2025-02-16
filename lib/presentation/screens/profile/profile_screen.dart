import 'package:flutter/material.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedPronoun = '';
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Profile Header
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const UserAvatar(size: 100),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Ann Smith',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ann.smith@example.com',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Profile Sections
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Personal Information',
                  children: [
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      title: 'Full Name',
                      subtitle: 'Ann Smith',
                      onTap: () {},
                    ),
                    _buildInfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: 'ann.smith@example.com',
                      onTap: () {},
                    ),
                    _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      subtitle: 'Add your location',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Preferences',
                  children: [
                    _buildLanguageSelector(),
                    _buildPronounSelector(),
                    _buildDarkModeToggle(),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4AF4),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4A4AF4)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      leading: const Icon(Icons.language, color: Color(0xFF4A4AF4)),
      title: const Text('Preferred Language'),
      trailing: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.black87,
                displayColor: Colors.black87,
              ),
        ),
        child: DropdownButton<String>(
          value: _selectedLanguage,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(
              value: 'English',
              child: Text(
                'English',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            DropdownMenuItem(
              value: 'Spanish',
              child: Text(
                'Spanish',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            DropdownMenuItem(
              value: 'French',
              child: Text(
                'French',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _selectedLanguage = value!),
        ),
      ),
    );
  }

  Widget _buildPronounSelector() {
    return ListTile(
      leading: const Icon(Icons.person, color: Color(0xFF4A4AF4)),
      title: const Text('Pronouns'),
      trailing: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.black87,
                displayColor: Colors.black87,
              ),
        ),
        child: DropdownButton<String>(
          value: _selectedPronoun.isEmpty ? null : _selectedPronoun,
          hint: const Text('Select', style: TextStyle(color: Colors.black87)),
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(
              value: 'He/Him',
              child: Text(
                'He/Him',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            DropdownMenuItem(
              value: 'She/Her',
              child: Text(
                'She/Her',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            DropdownMenuItem(
              value: 'They/Them',
              child: Text(
                'They/Them',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            DropdownMenuItem(
              value: 'Prefer not to say',
              child: Text(
                'Prefer not to say',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _selectedPronoun = value!),
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return SwitchListTile(
      secondary: Icon(
        _isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: const Color(0xFF4A4AF4),
      ),
      title: const Text('Dark Mode'),
      value: _isDarkMode,
      onChanged: (value) => setState(() => _isDarkMode = value),
    );
  }
}
