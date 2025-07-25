import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:knowledge/core/services/subscription_service.dart';
import 'package:knowledge/core/utils/debug_utils.dart';

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
      await _subscriptionService.setUserId(userId);
      await checkSubscriptionStatus();
    } catch (e) {
      DebugUtils.debugError('Failed to set user ID: $e');
    }
  }

  Future<void> logOut() async {
    try {
      await _subscriptionService.logOut();

      state = const SubscriptionState(
        isSubscribed: false,
        currentPlan: SubscriptionPlan.free,
      );
    } catch (e) {
      DebugUtils.debugError('Failed to log out from subscription service: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
