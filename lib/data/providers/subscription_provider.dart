import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_provider.g.dart';

enum SubscriptionPlan {
  free,
  weekly,
  monthly,
  yearly,
}

class SubscriptionState {
  final bool isSubscribed;
  final SubscriptionPlan currentPlan;
  final DateTime? expiryDate;

  const SubscriptionState({
    required this.isSubscribed,
    required this.currentPlan,
    this.expiryDate,
  });

  SubscriptionState copyWith({
    bool? isSubscribed,
    SubscriptionPlan? currentPlan,
    DateTime? expiryDate,
  }) {
    return SubscriptionState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      currentPlan: currentPlan ?? this.currentPlan,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  SubscriptionState build() {
    // Default state - user is not subscribed
    return const SubscriptionState(
      isSubscribed: false,
      currentPlan: SubscriptionPlan.free,
    );
  }

  Future<void> subscribe(SubscriptionPlan plan) async {
    // In a real app, this would handle payment processing
    // For now, we'll just update the state

    DateTime? expiryDate;
    final now = DateTime.now();

    switch (plan) {
      case SubscriptionPlan.weekly:
        expiryDate = now.add(const Duration(days: 7));
        break;
      case SubscriptionPlan.monthly:
        expiryDate = DateTime(now.year, now.month + 1, now.day);
        break;
      case SubscriptionPlan.yearly:
        expiryDate = DateTime(now.year + 1, now.month, now.day);
        break;
      case SubscriptionPlan.free:
        expiryDate = null;
        break;
    }

    state = SubscriptionState(
      isSubscribed: plan != SubscriptionPlan.free,
      currentPlan: plan,
      expiryDate: expiryDate,
    );
  }

  void cancelSubscription() {
    state = const SubscriptionState(
      isSubscribed: false,
      currentPlan: SubscriptionPlan.free,
    );
  }
}
