import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:knowledge/core/utils/debug_utils.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _isInitialized = false;

  static const String monthlyProductId = 'pro_subscription_1month';
  static const String yearlyProductId = 'pro_subscription_1y';

  /// Initialize RevenueCat SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final apiKey = dotenv.env['REVENUECAT_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('REVENUECAT_API_KEY not found in .env file');
      }

      // Configure RevenueCat
      PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);

      await Purchases.configure(configuration);

      // Set debug logs level
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);

      _isInitialized = true;
      DebugUtils.debugLog('RevenueCat initialized successfully');
    } catch (e) {
      DebugUtils.debugError('Failed to initialize RevenueCat: $e');
      rethrow;
    }
  }

  /// Set user ID for RevenueCat
  Future<void> setUserId(String userId) async {
    try {
      await _ensureInitialized();
      await Purchases.logIn(userId);
      DebugUtils.debugLog('RevenueCat user ID set: $userId');
    } catch (e) {
      DebugUtils.debugError('Failed to set user ID: $e');
    }
  }

  /// Get available offerings
  Future<Offerings?> getOfferings() async {
    try {
      await _ensureInitialized();
      final offerings = await Purchases.getOfferings();
      DebugUtils.debugLog(
          'Retrieved offerings: ${offerings.current?.availablePackages.length ?? 0} packages');
      return offerings;
    } catch (e) {
      DebugUtils.debugError('Failed to get offerings: $e');
      return null;
    }
  }

  /// Purchase a product
  Future<PurchaseResult> purchaseProduct(String productId) async {
    try {
      await _ensureInitialized();

      DebugUtils.debugLog('Attempting to purchase product: $productId');

      // Get offerings first
      final offerings = await getOfferings();
      if (offerings?.current == null) {
        throw Exception('No offerings available');
      }

      // Find the package with the matching product ID
      Package? packageToPurchase;
      for (final package in offerings!.current!.availablePackages) {
        if (package.storeProduct.identifier == productId) {
          packageToPurchase = package;
          break;
        }
      }

      if (packageToPurchase == null) {
        throw Exception('Product $productId not found in offerings');
      }

      // Make the purchase
      final customerInfo = await Purchases.purchasePackage(packageToPurchase);

      DebugUtils.debugLog('Purchase successful for product: $productId');

      return PurchaseResult(
        success: true,
        customerInfo: customerInfo,
        error: null,
      );
    } on PlatformException catch (e) {
      DebugUtils.debugError(
          'Purchase failed with PlatformException: ${e.message}');

      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      String errorMessage = 'Purchase failed';

      switch (errorCode) {
        case PurchasesErrorCode.purchaseCancelledError:
          errorMessage = 'Purchase was cancelled';
          break;
        case PurchasesErrorCode.purchaseNotAllowedError:
          errorMessage = 'Purchase not allowed';
          break;
        case PurchasesErrorCode.purchaseInvalidError:
          errorMessage = 'Purchase invalid';
          break;
        case PurchasesErrorCode.productNotAvailableForPurchaseError:
          errorMessage = 'Product not available for purchase';
          break;
        case PurchasesErrorCode.networkError:
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage = e.message ?? 'Unknown purchase error';
      }

      return PurchaseResult(
        success: false,
        customerInfo: null,
        error: errorMessage,
      );
    } catch (e) {
      DebugUtils.debugError('Purchase failed with error: $e');
      return PurchaseResult(
        success: false,
        customerInfo: null,
        error: e.toString(),
      );
    }
  }

  /// Restore purchases
  Future<CustomerInfo?> restorePurchases() async {
    try {
      await _ensureInitialized();
      final customerInfo = await Purchases.restorePurchases();
      DebugUtils.debugLog('Purchases restored successfully');
      return customerInfo;
    } catch (e) {
      DebugUtils.debugError('Failed to restore purchases: $e');
      return null;
    }
  }

  /// Get customer info
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      await _ensureInitialized();
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
      DebugUtils.debugError('Failed to get customer info: $e');
      return null;
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) return false;

      // Check if user has any active entitlements
      final hasActiveEntitlement = customerInfo.entitlements.active.isNotEmpty;

      DebugUtils.debugLog('Active subscription status: $hasActiveEntitlement');
      return hasActiveEntitlement;
    } catch (e) {
      DebugUtils.debugError('Failed to check subscription status: $e');
      return false;
    }
  }

  /// Check if user has specific product subscription
  Future<bool> hasProductSubscription(String productId) async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) return false;

      // Check active purchases
      final activePurchases = customerInfo.activeSubscriptions;
      final hasProduct = activePurchases.contains(productId);

      DebugUtils.debugLog(
          'Product $productId subscription status: $hasProduct');
      return hasProduct;
    } catch (e) {
      DebugUtils.debugError('Failed to check product subscription: $e');
      return false;
    }
  }

  /// Log out user
  Future<void> logOut() async {
    try {
      await _ensureInitialized();
      await Purchases.logOut();
      DebugUtils.debugLog('RevenueCat user logged out');
    } catch (e) {
      DebugUtils.debugError('Failed to log out user: $e');
    }
  }

  /// Ensure RevenueCat is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}

/// Result class for purchase operations
class PurchaseResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final String? error;

  PurchaseResult({
    required this.success,
    this.customerInfo,
    this.error,
  });
}
