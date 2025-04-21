import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/providers/feedback_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeedbackDialog extends HookConsumerWidget {
  const FeedbackDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRating = useState<String?>(null);
    final feedbackController = useTextEditingController();
    final isSubmitting = useState(false);
    final isLoading = useState(true);

    // Load previous feedback data if available
    useEffect(() {
      Future<void> loadPreviousFeedback() async {
        final feedbackNotifier = ref.read(feedbackNotifierProvider.notifier);

        // Get last rating and text
        final lastRating = await feedbackNotifier.getLastFeedbackRating();
        final lastText = await feedbackNotifier.getLastFeedbackText();

        // If we have previous feedback, set it as initial values
        if (lastRating != null) {
          selectedRating.value = lastRating;
        }

        if (lastText != null) {
          feedbackController.text = lastText;
        }

        isLoading.value = false;
      }

      loadPreviousFeedback();
      return null;
    }, []);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.navyBlue,
                    Color(0xFF3949AB),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.feedback_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'How\'s your experience with us?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content
            if (isLoading.value)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRatingOption(
                          context,
                          title: 'Poor',
                          icon: Icons.sentiment_very_dissatisfied,
                          color: Colors.redAccent,
                          isSelected: selectedRating.value == 'Poor',
                          onTap: () => selectedRating.value = 'Poor',
                        ),
                        _buildRatingOption(
                          context,
                          title: 'Good',
                          icon: Icons.sentiment_satisfied_alt,
                          color: Colors.amber,
                          isSelected: selectedRating.value == 'Good',
                          onTap: () => selectedRating.value = 'Good',
                        ),
                        _buildRatingOption(
                          context,
                          title: 'Awesome',
                          icon: Icons.sentiment_very_satisfied,
                          color: AppColors.limeGreen,
                          isSelected: selectedRating.value == 'Awesome',
                          onTap: () => selectedRating.value = 'Awesome',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Text field
                    Text(
                      'Tell us more about your experience',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'What did you like or dislike?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.limeGreen),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),

            // Buttons
            if (!isLoading.value)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navyBlue,
                          side: const BorderSide(
                            color: AppColors.navyBlue,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            selectedRating.value == null || isSubmitting.value
                                ? null
                                : () async {
                                    isSubmitting.value = true;
                                    final feedbackText =
                                        '${selectedRating.value}: ${feedbackController.text.trim()}';

                                    final success = await ref
                                        .read(feedbackNotifierProvider.notifier)
                                        .submitFeedback(feedbackText);

                                    if (context.mounted) {
                                      isSubmitting.value = false;
                                      Navigator.pop(context, success);
                                    }
                                  },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.limeGreen,
                          foregroundColor: AppColors.navyBlue,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: isSubmitting.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.navyBlue,
                                  ),
                                ),
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
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

  Widget _buildRatingOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ).animate(target: isSelected ? 1 : 0).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: const Duration(milliseconds: 200),
            ),
      ),
    );
  }
}
