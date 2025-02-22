import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  String _selectedPronoun = '';
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Ann Smith');
    _locationController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding + 80),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        child: UserAvatar(size: 100),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1A1A1A),
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            // Handle image picker
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _locationController,
                        label: 'Location',
                        icon: Icons.location_on_outlined,
                        hintText: 'Add your location',
                      ),
                      const SizedBox(height: 24),
                      _buildDropdownField(
                        label: 'Pronouns',
                        icon: Icons.person,
                        value:
                            _selectedPronoun.isEmpty ? null : _selectedPronoun,
                        items: const [
                          'He/Him',
                          'She/Her',
                          'They/Them',
                          'Prefer not to say',
                        ],
                        onChanged: (value) {
                          setState(() => _selectedPronoun = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: 'Preferred Language',
                        icon: Icons.language,
                        value: _selectedLanguage,
                        items: const ['English', 'Spanish', 'French'],
                        onChanged: (value) {
                          setState(() => _selectedLanguage = value!);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: const TextStyle(color: Colors.blue),
          prefixIcon: Icon(icon, color: Colors.blue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: const TextStyle(color: Colors.blue)),
        trailing: DropdownButton<String>(
          value: value,
          hint: Text('Select', style: TextStyle(color: Colors.grey[600])),
          dropdownColor: Colors.grey[900],
          underline: const SizedBox(),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Save profile changes
      context.pop();
    }
  }
}
