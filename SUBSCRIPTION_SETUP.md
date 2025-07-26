# Subscription Setup Guide

This guide will help you set up the RevenueCat subscription functionality in your Knowledge Flutter app.

## Prerequisites

1. **App Store Connect**: Your app should be set up in App Store Connect
2. **RevenueCat Account**: Create a RevenueCat account at [revenuecat.com](https://revenuecat.com)
3. **Product IDs**: Ensure your product IDs are created in App Store Connect

## Product Configuration

### App Store Connect Products
Make sure you have created the following subscription products in App Store Connect:

- **Monthly Subscription**: `pro_subscription_1month` - $12/month
- **Yearly Subscription**: `pro_subscription_1y` - $99/year

### RevenueCat Configuration

1. **Create RevenueCat Project**:
   - Go to RevenueCat dashboard
   - Create a new project
   - Add your iOS app with the Bundle ID

2. **Configure Products**:
   - Go to Products section
   - Add your products with the same identifiers:
     - `pro_subscription_1month`
     - `pro_subscription_1y`

3. **Set up Entitlements**:
   - Create an entitlement (e.g., "pro")
   - Attach both products to this entitlement

## Environment Configuration

1. **Copy the example environment file**:
   ```bash
   cp .env.example .env
   ```

2. **Update your `.env` file** with your actual values:
   ```env
   # API Configuration
   API_BASE_URL=your_actual_api_url
   MEDIA_BASE_URL=your_actual_media_url
   
   # Supabase Configuration  
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   
   # RevenueCat Configuration
   REVENUECAT_API_KEY=appl_WCGhrSypJDKjAEYGgirthQUmxEo
   
   # Environment
   ENVIRONMENT=development
   ```

## iOS Configuration

### 1. Capabilities
Add the **In-App Purchase** capability to your iOS app:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your target
3. Go to "Signing & Capabilities"
4. Click "+" and add "In-App Purchase"

### 2. Info.plist (Optional)
If you want to disable StoreKit configuration file validation during development, add this to `ios/Runner/Info.plist`:

```xml
<key>REVENUECAT_DISABLE_STOREKIT_CONFIG_FILE_VALIDATION</key>
<true/>
```

## Testing

### 1. Sandbox Testing
- Create sandbox test users in App Store Connect
- Use these accounts for testing purchases
- Test both monthly and yearly subscriptions

### 2. Debug Mode
The app automatically enables debug logging in development mode. Check your console for RevenueCat logs.

## Implementation Details

### Key Files
- `lib/core/services/subscription_service.dart` - RevenueCat integration service
- `lib/data/providers/subscription_provider.dart` - Riverpod state management
- `lib/presentation/screens/subscription/select_plan_screen.dart` - Subscription UI

### Usage in Code

```dart
// Get subscription state
final subscriptionState = ref.watch(subscriptionNotifierProvider);

// Subscribe to a plan
final notifier = ref.read(subscriptionNotifierProvider.notifier);
final success = await notifier.subscribe(SubscriptionPlan.yearly);

// Check subscription status
final isSubscribed = subscriptionState.isSubscribed;
final currentPlan = subscriptionState.currentPlan;
```

### Subscription Flow

1. **User selects a plan** on the SelectPlanScreen
2. **Purchase is processed** through RevenueCat and Apple App Store
3. **Profile is updated** with `is_premium: true` via PATCH `/auth/user/me`
4. **User is redirected** to Pro Onboarding Screen for personalized experience setup
5. **Subscription status is synced** across the app

### Error Handling
The implementation includes comprehensive error handling for:
- Network errors
- Cancelled purchases
- Invalid products
- User permission issues

## Troubleshooting

### Common Issues

1. **"Product not found" error**:
   - Verify product IDs match exactly in App Store Connect and RevenueCat
   - Ensure products are in "Ready for Review" status
   - Check that RevenueCat has synced with App Store Connect

2. **"Invalid API key" error**:
   - Double-check the RevenueCat API key in your `.env` file
   - Ensure you're using the correct key for your platform (iOS)

3. **Purchases not working**:
   - Test with sandbox accounts
   - Verify In-App Purchase capability is enabled
   - Check RevenueCat dashboard for transaction logs

### Debug Steps

1. **Enable Debug Logging**:
   ```dart
   await Purchases.setLogLevel(LogLevel.debug);
   ```

2. **Check Customer Info**:
   ```dart
   final customerInfo = await Purchases.getCustomerInfo();
   print('Active subscriptions: ${customerInfo.activeSubscriptions}');
   print('Entitlements: ${customerInfo.entitlements.active}');
   ```

3. **Verify Offerings**:
   ```dart
   final offerings = await Purchases.getOfferings();
   print('Available packages: ${offerings.current?.availablePackages}');
   ```

## Production Deployment

Before releasing to production:

1. **Update Environment**: Change `ENVIRONMENT=production` in your `.env`
2. **Test with TestFlight**: Test the full purchase flow with TestFlight
3. **Monitor RevenueCat Dashboard**: Keep an eye on the dashboard for any issues
4. **Set up Webhooks**: Configure webhooks for server-side validation if needed

## Support

- **RevenueCat Documentation**: [docs.revenuecat.com](https://docs.revenuecat.com)
- **Flutter Plugin**: [pub.dev/packages/purchases_flutter](https://pub.dev/packages/purchases_flutter)
- **App Store Connect Help**: [developer.apple.com](https://developer.apple.com/app-store-connect/) 