import 'package:flutter/material.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:go_router/go_router.dart';

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
    // Get safe area padding
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image or pattern (optional)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.withOpacity(0.2),
                          Colors.purple.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          const Color(0xFF1A1A1A),
                        ],
                        stops: const [0.0, 0.6, 0.9],
                      ),
                    ),
                  ),
                  // Profile content
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Profile image section
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // Outer decorative ring
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                ),
                              ),
                            ),
                            // Profile image container
                            Container(
                              width: 134,
                              height: 134,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1A1A1A),
                                  width: 4,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(67),
                                child: const UserAvatar(size: 130),
                              ),
                            ),
                            // Camera button
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // Handle camera tap
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF1A1A1A),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Name with verification badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ann Smith',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              color: Colors.blue.shade400,
                              size: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Email with custom style
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: Colors.blue.shade200,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ann.smith@example.com',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => context.push('/profile/edit'),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, safePadding.bottom + 16),
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
                      const Divider(height: 1, color: Colors.grey),
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: 'ann.smith@example.com',
                        onTap: () {},
                      ),
                      const Divider(height: 1, color: Colors.grey),
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
                      const Divider(height: 1, color: Colors.grey),
                      _buildPronounSelector(),
                      const Divider(height: 1, color: Colors.grey),
                      _buildDarkModeToggle(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[800]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: children,
            ),
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
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
      onTap: onTap,
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      leading: Icon(Icons.language, color: Colors.blue),
      title: const Text('Preferred Language',
          style: TextStyle(color: Colors.white)),
      trailing: Theme(
        data: Theme.of(context).copyWith(
          dropdownMenuTheme: DropdownMenuThemeData(
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
        child: DropdownButton<String>(
          value: _selectedLanguage,
          underline: const SizedBox(),
          dropdownColor: Colors.grey[900],
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          items: const [
            DropdownMenuItem(
              value: 'English',
              child: Text('English', style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'Spanish',
              child: Text('Spanish', style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'French',
              child: Text('French', style: TextStyle(color: Colors.white)),
            ),
          ],
          onChanged: (value) => setState(() => _selectedLanguage = value!),
        ),
      ),
    );
  }

  Widget _buildPronounSelector() {
    return ListTile(
      leading: Icon(Icons.person, color: Colors.blue),
      title: const Text('Pronouns', style: TextStyle(color: Colors.white)),
      trailing: Theme(
        data: Theme.of(context).copyWith(
          dropdownMenuTheme: DropdownMenuThemeData(
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
        child: DropdownButton<String>(
          value: _selectedPronoun.isEmpty ? null : _selectedPronoun,
          hint: Text('Select', style: TextStyle(color: Colors.grey[400])),
          underline: const SizedBox(),
          dropdownColor: Colors.grey[900],
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          items: const [
            DropdownMenuItem(
              value: 'He/Him',
              child: Text('He/Him', style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'She/Her',
              child: Text('She/Her', style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'They/Them',
              child: Text('They/Them', style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem(
              value: 'Prefer not to say',
              child: Text('Prefer not to say',
                  style: TextStyle(color: Colors.white)),
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
        color: Colors.blue,
      ),
      title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
      value: _isDarkMode,
      onChanged: (value) => setState(() => _isDarkMode = value),
    );
  }
}
