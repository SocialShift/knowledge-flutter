import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/repositories/bookmark_repository.dart';

class BookmarkIcon extends HookConsumerWidget {
  final String timelineId;
  final double size;
  final Color? defaultColor;
  final bool showBackground;
  final bool showInstantFeedback;
  final Function(bool isBookmarked, String message)? onToggleComplete;

  const BookmarkIcon({
    super.key,
    required this.timelineId,
    this.size = 24,
    this.defaultColor,
    this.showBackground = true,
    this.showInstantFeedback = false,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkStatusAsync = ref.watch(bookmarkStatusProvider(timelineId));
    final toggleBookmark = ref.read(toggleBookmarkProvider);

    // Local state for instant visual feedback
    final localBookmarkState = useState<bool?>(null);
    final isProcessing = useState(false);

    return bookmarkStatusAsync.when(
      loading: () => Container(
        width: size + 16,
        height: size + 16,
        decoration: showBackground
            ? BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              )
            : null,
        child: Center(
          child: SizedBox(
            width: size * 0.6,
            height: size * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                defaultColor ?? AppColors.limeGreen,
              ),
            ),
          ),
        ),
      ),
      error: (error, stack) => Container(
        width: size + 16,
        height: size + 16,
        decoration: showBackground
            ? BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              )
            : null,
        child: Icon(
          Icons.bookmark_border,
          size: size,
          color: defaultColor ?? Colors.white.withOpacity(0.7),
        ),
      ),
      data: (serverBookmarkState) {
        // Use local state if available, otherwise use server state
        final currentBookmarkState =
            localBookmarkState.value ?? serverBookmarkState;

        return GestureDetector(
          onTap: isProcessing.value
              ? null
              : () async {
                  if (showInstantFeedback) {
                    // Instantly update local state for immediate visual feedback
                    localBookmarkState.value = !currentBookmarkState;
                    isProcessing.value = true;
                  }

                  try {
                    final result = await toggleBookmark(timelineId);
                    final newBookmarkState = result['bookmarked'] as bool;

                    if (showInstantFeedback) {
                      // Update local state with server response
                      localBookmarkState.value = newBookmarkState;

                      // Call completion callback if provided
                      if (onToggleComplete != null) {
                        onToggleComplete!(
                          newBookmarkState,
                          newBookmarkState
                              ? 'Bookmarked successfully!'
                              : 'Bookmark removed',
                        );
                      }
                    }
                  } catch (e) {
                    if (showInstantFeedback) {
                      // Revert local state on error
                      localBookmarkState.value = serverBookmarkState;
                    }

                    // Show error message if needed
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } finally {
                    if (showInstantFeedback) {
                      isProcessing.value = false;
                    }
                  }
                },
          child: Container(
            width: size + 16,
            height: size + 16,
            decoration: showBackground
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  )
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  currentBookmarkState ? Icons.bookmark : Icons.bookmark_border,
                  size: size,
                  color: currentBookmarkState
                      ? AppColors.limeGreen
                      : defaultColor ?? Colors.white.withOpacity(0.7),
                ),
                // Show small loading indicator if processing in instant feedback mode
                if (showInstantFeedback && isProcessing.value)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.limeGreen,
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
