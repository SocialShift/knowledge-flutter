import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/providers/community_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CreateCommunityScreen extends HookConsumerWidget {
  const CreateCommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final isLoading = useState(false);
    final bannerImage = useState<File?>(null);
    final iconImage = useState<File?>(null);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Categories from community_screen.dart
    final categories = [
      {'id': '1', 'name': 'Indigenous Histories', 'icon': '🏛️'},
      {'id': '2', 'name': 'African Diaspora', 'icon': '🌍'},
      {'id': '3', 'name': 'LGBTQ+ Movements', 'icon': '🏳️‍🌈'},
      {'id': '4', 'name': 'Women\'s History', 'icon': '👩'},
      {'id': '5', 'name': 'Civil Rights', 'icon': '✊'},
      {'id': '6', 'name': 'Lesser-Known Figures', 'icon': '📚'},
      {'id': '7', 'name': 'Colonial History', 'icon': '🗺️'},
      {'id': '8', 'name': 'Immigrant Stories', 'icon': '🚢'},
    ];

    // Selected categories state
    final selectedCategories = useState<List<String>>([]);

    Future<void> pickImage(bool isIcon) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: isIcon ? 500 : 1200,
        maxHeight: isIcon ? 500 : 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (isIcon) {
          iconImage.value = File(pickedFile.path);
        } else {
          bannerImage.value = File(pickedFile.path);
        }
      }
    }

    Future<void> createCommunity() async {
      if (nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a community name'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if icon image is selected (now mandatory)
      if (iconImage.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a community icon image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if at least one category is selected
      if (selectedCategories.value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one topic category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      isLoading.value = true;

      try {
        // Convert selected categories to comma-separated string for the API
        final topics = selectedCategories.value.map((id) {
          final category = categories.firstWhere((cat) => cat['id'] == id);
          return category['name'];
        }).join(', ');

        await ref.read(communityActionsProvider.notifier).createCommunity(
              name: nameController.text.trim(),
              description: descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
              topics: topics,
              bannerFile: bannerImage.value,
              iconFile: iconImage.value,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Community created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create community: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : AppColors.navyBlue,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Community',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.navyBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.groups,
                    size: 48,
                    color: AppColors.limeGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start Your Community',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: isDarkMode ? Colors.white : AppColors.navyBlue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a space for like-minded history enthusiasts to connect and learn together.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form
            _buildFormField(
              context,
              title: 'Community Name *',
              hint: 'Enter community name',
              controller: nameController,
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 20),

            _buildFormField(
              context,
              title: 'Description',
              hint: 'Tell others what your community is about',
              controller: descriptionController,
              isDarkMode: isDarkMode,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Topics/Categories Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Topics *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : AppColors.navyBlue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select categories that best describe your community (select at least one)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            isDarkMode ? Colors.white70 : Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 16),

                // Categories grid with circular icons
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimationLimiter(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected =
                            selectedCategories.value.contains(category['id']);

                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          columnCount: 4,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: GestureDetector(
                                onTap: () {
                                  final newSelected = List<String>.from(
                                      selectedCategories.value);
                                  if (isSelected) {
                                    newSelected.remove(category['id']);
                                  } else {
                                    newSelected.add(category['id'] as String);
                                  }
                                  selectedCategories.value = newSelected;
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.limeGreen
                                            : (isDarkMode
                                                ? AppColors.darkCard
                                                : Colors.white),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.navyBlue
                                              : isDarkMode
                                                  ? Colors.grey.shade700
                                                  : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          category['icon'] as String,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category['name'] as String,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isSelected
                                                ? AppColors.navyBlue
                                                : (isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black87),
                                            fontSize: 10,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Image uploads
            Text(
              'Images',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.navyBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildImagePicker(
                    context,
                    title: 'Community Icon *',
                    subtitle: 'Square image required',
                    image: iconImage.value,
                    onTap: () => pickImage(true),
                    isDarkMode: isDarkMode,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImagePicker(
                    context,
                    title: 'Banner Image',
                    subtitle: 'Wide image recommended',
                    image: bannerImage.value,
                    onTap: () => pickImage(false),
                    isDarkMode: isDarkMode,
                    isRequired: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Create button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading.value ? null : createCommunity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.limeGreen,
                  foregroundColor: AppColors.navyBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.navyBlue,
                        ),
                      )
                    : Text(
                        'Create Community',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyBlue,
                                ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required String title,
    required String hint,
    required TextEditingController controller,
    required bool isDarkMode,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDarkMode ? Colors.white : AppColors.navyBlue,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.navyBlue,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white54 : Colors.grey.shade500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(
    BuildContext context, {
    required String title,
    required String subtitle,
    required File? image,
    required VoidCallback onTap,
    required bool isDarkMode,
    required bool isRequired,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRequired && image == null
                ? Colors.red.withOpacity(0.7)
                : AppColors.limeGreen.withOpacity(0.3),
            width: isRequired && image == null ? 2 : 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    if (isRequired)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Required',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: isRequired && image == null
                        ? Colors.red.withOpacity(0.7)
                        : AppColors.limeGreen,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.navyBlue,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      if (isRequired)
                        Text(
                          ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? Colors.white54
                              : Colors.grey.shade500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
