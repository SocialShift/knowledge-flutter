import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:knowledge/core/services/subscription_service.dart';
import 'package:knowledge/core/utils/debug_utils.dart';
import 'package:knowledge/data/repositories/profile_repository.dart';
import 'package:knowledge/data/providers/profile_provider.dart'
    as profile_provider;

part 'subscription_provider.g.dart';

enum SubscriptionPlan {
  free,
  monthly,
  yearly,
}

extension SubscriptionPlanExtension on SubscriptionPlan {
  String get productId {
    switch (this) {
      case SubscriptionPlan.monthly:
        return SubscriptionService.monthlyProductId;
      case SubscriptionPlan.yearly:
        return SubscriptionService.yearlyProductId;
      case SubscriptionPlan.free:
        return '';
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionPlan.monthly:
        return 'Monthly';
      case SubscriptionPlan.yearly:
        return 'Yearly';
      case SubscriptionPlan.free:
        return 'Free';
    }
  }

  String get price {
    switch (this) {
      case SubscriptionPlan.monthly:
        return '\$12';
      case SubscriptionPlan.yearly:
        return '\$99';
      case SubscriptionPlan.free:
        return '\$0';
    }
  }
}

class SubscriptionState {
  final bool isSubscribed;
  final SubscriptionPlan currentPlan;
  final DateTime? expiryDate;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    required this.isSubscribed,
    required this.currentPlan,
    this.expiryDate,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isSubscribed,
    SubscriptionPlan? currentPlan,
    DateTime? expiryDate,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      currentPlan: currentPlan ?? this.currentPlan,
      expiryDate: expiryDate ?? this.expiryDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  final _subscriptionService = SubscriptionService();

  @override
  SubscriptionState build() {
    // Initialize subscription service
    _initializeService();

    return const SubscriptionState(
      isSubscribed: false,
      currentPlan: SubscriptionPlan.free,
    );
  }

  Future<void> _initializeService() async {
    try {
      await _subscriptionService.initialize();
      await checkSubscriptionStatus();
    } catch (e) {
      DebugUtils.debugError('Failed to initialize subscription service: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final customerInfo = await _subscriptionService.getCustomerInfo();

      if (customerInfo == null) {
        state = state.copyWith(
          isSubscribed: false,
          currentPlan: SubscriptionPlan.free,
          isLoading: false,
        );
        return;
      }

      final hasActiveSubscription = customerInfo.entitlements.active.isNotEmpty;

      SubscriptionPlan currentPlan = SubscriptionPlan.free;

      if (hasActiveSubscription) {
        final activePurchases = customerInfo.activeSubscriptions;

        if (activePurchases.contains(SubscriptionService.yearlyProductId)) {
          currentPlan = SubscriptionPlan.yearly;
        } else if (activePurchases
            .contains(SubscriptionService.monthlyProductId)) {
          currentPlan = SubscriptionPlan.monthly;
        }
      }

      // Validate entitlements for current user before updating premium status
      if (hasActiveSubscription) {
        // Double-check entitlements are valid for current user
        final isValidEntitlement =
            await _subscriptionService.validateCurrentUserEntitlements();

        if (isValidEntitlement) {
          try {
            final profileRepository = ProfileRepository();
            await profileRepository.updatePremiumStatus(true);
            ref.invalidate(profile_provider.userProfileProvider);
            DebugUtils.debugLog(
                'Premium status updated to true after entitlement validation');
          } catch (e) {
            DebugUtils.debugError('Failed to update premium status: $e');
          }
        } else {
          DebugUtils.debugError(
              'Active subscription found but entitlement validation failed - not updating premium status');
        }
      } else {
        DebugUtils.debugLog(
            'No active subscription found - not updating premium status');
      }

      state = state.copyWith(
        isSubscribed: hasActiveSubscription,
        currentPlan: currentPlan,
        isLoading: false,
      );

      DebugUtils.debugLog(
          'Subscription status: isSubscribed=$hasActiveSubscription, plan=${currentPlan.displayName}');
    } catch (e) {
      DebugUtils.debugError('Failed to check subscription status: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> subscribe(SubscriptionPlan plan) async {
    if (plan == SubscriptionPlan.free) return false;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _subscriptionService.purchaseProduct(plan.productId);

      if (result.success) {
        // Validate that the current user actually has the entitlement
        final customerInfo = result.customerInfo;
        if (customerInfo != null &&
            customerInfo.entitlements.active.isNotEmpty) {
          // Update premium status in profile API only after validating entitlement
          try {
            final profileRepository = ProfileRepository();
            await profileRepository.updatePremiumStatus(true);

            // Invalidate profile provider to refresh the profile data
            ref.invalidate(profile_provider.userProfileProvider);

            DebugUtils.debugLog(
                'Premium status updated in profile after entitlement validation');
          } catch (e) {
            DebugUtils.debugError(
                'Failed to update premium status in profile: $e');
            // Don't fail the entire subscription process if profile update fails
          }
        } else {
          DebugUtils.debugError(
              'Purchase succeeded but no active entitlements found - not updating premium status');
        }

        state = state.copyWith(
          isSubscribed: true,
          currentPlan: plan,
          isLoading: false,
        );

        DebugUtils.debugLog('Successfully subscribed to ${plan.displayName}');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
        return false;
      }
    } catch (e) {
      DebugUtils.debugError('Subscription failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final customerInfo = await _subscriptionService.restorePurchases();

      if (customerInfo != null) {
        final hasActiveSubscription =
            customerInfo.entitlements.active.isNotEmpty;

        SubscriptionPlan currentPlan = SubscriptionPlan.free;

        if (hasActiveSubscription) {
          final activePurchases = customerInfo.activeSubscriptions;

          if (activePurchases.contains(SubscriptionService.yearlyProductId)) {
            currentPlan = SubscriptionPlan.yearly;
          } else if (activePurchases
              .contains(SubscriptionService.monthlyProductId)) {
            currentPlan = SubscriptionPlan.monthly;
          }

          // Validate entitlements before updating premium status during restore
          final isValidEntitlement =
              await _subscriptionService.validateCurrentUserEntitlements();

          if (isValidEntitlement) {
            try {
              final profileRepository = ProfileRepository();
              await profileRepository.updatePremiumStatus(true);
              ref.invalidate(profile_provider.userProfileProvider);
              DebugUtils.debugLog(
                  'Premium status updated in profile during restore after validation');
            } catch (e) {
              DebugUtils.debugError(
                  'Failed to update premium status during restore: $e');
            }
          } else {
            DebugUtils.debugError(
                'Restore found subscription but entitlement validation failed - not updating premium status');
          }
        } else {
          // Don't set premium to false - let backend manage this
          DebugUtils.debugLog(
              'No active subscription found during restore - not updating premium status');
        }

        state = state.copyWith(
          isSubscribed: hasActiveSubscription,
          currentPlan: currentPlan,
          isLoading: false,
        );

        DebugUtils.debugLog('Purchases restored successfully');
        return true;
      } else {
        state = state.copyWith(isLoading: false);
        return false;
      }
    } catch (e) {
      DebugUtils.debugError('Failed to restore purchases: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> setUserId(String userId) async {
    try {
      DebugUtils.debugLog('Setting subscription user ID: $userId');

      // Set user ID with proper isolation
      await _subscriptionService.setUserId(userId);

      // Check subscription status for this specific user
      await checkSubscriptionStatus();

      DebugUtils.debugLog(
          'Subscription user ID set and status checked for: $userId');
    } catch (e) {
      DebugUtils.debugError('Failed to set user ID: $e');
      // Reset to free state if user switching fails
      state = const SubscriptionState(
        isSubscribed: false,
        currentPlan: SubscriptionPlan.free,
      );
    }
  }

  Future<void> logOut() async {
    try {
      DebugUtils.debugLog('Logging out from subscription service');

      // Log out from RevenueCat to clear user-specific entitlements
      await _subscriptionService.logOut();

      // Reset to free state immediately
      state = const SubscriptionState(
        isSubscribed: false,
        currentPlan: SubscriptionPlan.free,
      );

      DebugUtils.debugLog('Subscription service logout completed');
    } catch (e) {
      DebugUtils.debugError('Failed to log out from subscription service: $e');
      // Still reset state even if logout fails
      state = const SubscriptionState(
        isSubscribed: false,
        currentPlan: SubscriptionPlan.free,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get subscription result with navigation info
  SubscriptionResult getSubscriptionResult() {
    return SubscriptionResult(
      isSubscribed: state.isSubscribed,
      currentPlan: state.currentPlan,
      shouldNavigateToProOnboarding: state.isSubscribed &&
          (state.currentPlan == SubscriptionPlan.monthly ||
              state.currentPlan == SubscriptionPlan.yearly),
    );
  }
}

/// Result class for subscription operations with navigation info
class SubscriptionResult {
  final bool isSubscribed;
  final SubscriptionPlan currentPlan;
  final bool shouldNavigateToProOnboarding;

  SubscriptionResult({
    required this.isSubscribed,
    required this.currentPlan,
    required this.shouldNavigateToProOnboarding,
  });
}
