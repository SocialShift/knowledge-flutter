import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/repositories/community_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReportDialog extends HookConsumerWidget {
  final String reportType; // "community" or "post"
  final int reportedItemId;
  final String itemName; // Community name or post title for context

  const ReportDialog({
    super.key,
    required this.reportType,
    required this.reportedItemId,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReason = useState<String?>(null);
    final descriptionController = useTextEditingController();
    final isSubmitting = useState(false);
    final showDescription = useState(false);
    final characterCount = useState(0);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Listen to text changes for character count
    useEffect(() {
      void listener() {
        characterCount.value = descriptionController.text.length;
      }

      descriptionController.addListener(listener);
      return () => descriptionController.removeListener(listener);
    }, [descriptionController]);

    // Report reasons with API values, display text, and icons
    final reasons = {
      'spam': {
        'text': 'Spam or misleading content',
        'icon': Icons.report_problem,
        'color': Colors.orange,
        'description': 'Unwanted promotional content or false information'
      },
      'harassment': {
        'text': 'Harassment or bullying',
        'icon': Icons.person_off,
        'color': Colors.red,
        'description': 'Targeting individuals with harmful behavior'
      },
      'hate_speech': {
        'text': 'Hate speech or discrimination',
        'icon': Icons.block,
        'color': Colors.deepOrange,
        'description': 'Content promoting hatred based on identity'
      },
      'violence': {
        'text': 'Violence or dangerous content',
        'icon': Icons.dangerous,
        'color': Colors.red.shade700,
        'description': 'Content depicting or promoting violence'
      },
      'nudity_sexual_content': {
        'text': 'Sexual or inappropriate content',
        'icon': Icons.visibility_off,
        'color': Colors.purple,
        'description': 'Adult content or sexually explicit material'
      },
      'copyright_violation': {
        'text': 'Copyright infringement',
        'icon': Icons.copyright,
        'color': Colors.blue,
        'description': 'Unauthorized use of copyrighted material'
      },
      'misinformation': {
        'text': 'Misinformation',
        'icon': Icons.fact_check,
        'color': Colors.amber,
        'description': 'False or misleading information'
      },
      'inappropriate_content': {
        'text': 'Inappropriate content',
        'icon': Icons.warning,
        'color': Colors.orange.shade700,
        'description': 'Content that violates community guidelines'
      },
      'illegal_activities': {
        'text': 'Illegal activities',
        'icon': Icons.gavel,
        'color': Colors.red.shade900,
        'description': 'Content promoting illegal behavior'
      },
      'other': {
        'text': 'Other',
        'icon': Icons.more_horiz,
        'color': Colors.grey,
        'description': 'Other violations not listed above'
      },
    };

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.navyBlue.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.flag,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Report ${reportType == "community" ? "Community" : "Post"}',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.navyBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                itemName,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Reports are reviewed by our moderation team and help keep the community safe.',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.blue.shade800,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.3, duration: 400.ms).fadeIn(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why are you reporting this ${reportType}?',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reason selection
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white24
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: reasons.entries.map((entry) {
                          final apiValue = entry.key;
                          final reasonData =
                              entry.value as Map<String, dynamic>;
                          final displayText = reasonData['text'] as String;
                          final icon = reasonData['icon'] as IconData;
                          final color = reasonData['color'] as Color;
                          final description =
                              reasonData['description'] as String;
                          final isSelected = selectedReason.value == apiValue;
                          final isLast = entry.key == reasons.keys.last;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                selectedReason.value = apiValue;
                                if (!showDescription.value) {
                                  showDescription.value = true;
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: color.withOpacity(0.3),
                                          width: 1.5)
                                      : !isLast
                                          ? Border(
                                              bottom: BorderSide(
                                                color: isDarkMode
                                                    ? Colors.white12
                                                    : Colors.grey.shade200,
                                                width: 1,
                                              ),
                                            )
                                          : null,
                                ),
                                child: Row(
                                  children: [
                                    // Icon with background
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? color.withOpacity(0.2)
                                            : color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: isSelected
                                            ? color
                                            : color.withOpacity(0.7),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayText,
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            description,
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white60
                                                  : Colors.grey.shade600,
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Radio button
                                    Radio<String>(
                                      value: apiValue,
                                      groupValue: selectedReason.value,
                                      onChanged: (value) {
                                        selectedReason.value = value;
                                        if (!showDescription.value) {
                                          showDescription.value = true;
                                        }
                                      },
                                      activeColor: color,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(
                              delay:
                                  (reasons.keys.toList().indexOf(apiValue) * 50)
                                      .ms);
                        }).toList(),
                      ),
                    ),

                    // Enhanced Description Section
                    if (selectedReason.value != null &&
                        showDescription.value) ...[
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: 20,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Additional Details',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.limeGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Optional',
                                    style: TextStyle(
                                      color: AppColors.limeGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.white24
                                      : Colors.grey.shade300,
                                ),
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.withOpacity(0.03),
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: descriptionController,
                                    maxLines: 4,
                                    maxLength: 500,
                                    buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) {
                                      return null; // Hide default counter
                                    },
                                    decoration: InputDecoration(
                                      hintText:
                                          'Help us understand the issue better by providing more context...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.limeGreen,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                  // Custom character counter
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Your report will help make our community safer',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: characterCount.value > 450
                                                ? Colors.orange.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${characterCount.value}/500',
                                            style: TextStyle(
                                              color: characterCount.value > 450
                                                  ? Colors.orange
                                                  : Colors.grey.shade600,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
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
                      ).animate().slideY(begin: 0.3, duration: 300.ms).fadeIn(),
                    ],
                  ],
                ),
              ),
            ),

            // Enhanced Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.03)
                    : Colors.grey.withOpacity(0.03),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: isSubmitting.value
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Submit Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: selectedReason.value == null ||
                              isSubmitting.value
                          ? null
                          : () async {
                              isSubmitting.value = true;
                              try {
                                final repository = CommunityRepository();
                                await repository.reportItem(
                                  reportType: reportType,
                                  reportedItemId: reportedItemId,
                                  reason: selectedReason.value!,
                                  description:
                                      descriptionController.text.trim(),
                                );

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Report submitted successfully',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                }
                              } catch (e) {
                                isSubmitting.value = false;
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error,
                                              color: Colors.white),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Failed to submit report: ${e.toString()}',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: Colors.red.withOpacity(0.3),
                      ),
                      child: isSubmitting.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Submitting...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flag, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Submit Report',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
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
}
