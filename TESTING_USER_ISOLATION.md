# Testing User Isolation for Subscriptions

This guide will help you test that subscriptions are properly isolated between different app users on the same device.

## 🧪 **Test Scenarios**

### Test 1: Basic User Isolation
1. **Login as User A** and subscribe to premium
2. **Verify**: User A has premium access and `is_premium: true` in backend
3. **Logout** User A
4. **Login as User B** (different account)
5. **Expected**: User B should NOT have premium access
6. **Expected**: User B's profile should have `is_premium: false`

### Test 2: Purchase Attempt by Second User
1. **Complete Test 1** above
2. **As User B**, try to purchase a subscription
3. **Expected**: Apple payment dialog should appear normally
4. **Expected**: User B can complete their own purchase
5. **Expected**: Both users should now have independent premium access

### Test 3: Cross-User Entitlement Check
1. **Login as User A** with active subscription
2. **Check RevenueCat dashboard**: Note User A's customer ID
3. **Logout and login as User B**
4. **Check RevenueCat dashboard**: User B should have different customer ID
5. **Expected**: User B should not inherit User A's entitlements

### Test 4: Device Switching
1. **User A subscribes on Device 1**
2. **User A logs in on Device 2**
3. **Expected**: User A should have premium on Device 2
4. **User B logs in on Device 1**
5. **Expected**: User B should NOT have premium (despite Device 1 having active subscription)

## 🔍 **Debug Steps**

### Check RevenueCat Logs
Look for these log messages in your debug console:

```
// User login
✅ "Logged out previous RevenueCat user"
✅ "RevenueCat user logged in: [userId]"
✅ "Customer entitlements: [entitlement_keys]"

// User logout
✅ "RevenueCat user logged out successfully"
✅ "Anonymous customer entitlements: []"

// Entitlement validation
✅ "Entitlement validation for user: [userId]"
✅ "Active entitlements: [entitlement_keys]"
✅ "Premium status updated to true after entitlement validation"

// Error cases
❌ "Active subscription found but entitlement validation failed"
❌ "Purchase succeeded but no active entitlements found"
```

### Backend API Verification
Monitor these API calls:

```bash
# Should only happen when entitlement is validated
PATCH /auth/profile/update
{
  "is_premium": "true"
}

# Should NOT happen when user switches without subscription
# (No PATCH call should be made)
```

### RevenueCat Dashboard Checks
1. Go to RevenueCat Dashboard → Customers
2. Search for each test user
3. Verify each user has separate customer records
4. Check that entitlements are tied to correct users

## 🚨 **Common Issues & Fixes**

### Issue: User B gets premium without paying
**Cause**: Entitlement validation not working
**Check**: Look for logs showing failed validation
**Fix**: Ensure proper user logout/login sequence

### Issue: No Apple payment dialog for User B
**Cause**: Purchase still tied to device, not user
**Check**: RevenueCat dashboard for duplicate customer entries
**Fix**: Ensure `Purchases.logOut()` is called before user switch

### Issue: Premium status not updating
**Cause**: Backend API call failing
**Check**: Network logs for PATCH request failures
**Fix**: Check API endpoint and FormData format

## 📋 **Checklist for Production**

Before releasing user isolation fix:

- [ ] Test with 2+ different Apple ID accounts
- [ ] Test on multiple physical devices
- [ ] Test with TestFlight builds (not just local debug)
- [ ] Verify RevenueCat webhook events are per-user
- [ ] Test restore purchases for each user independently
- [ ] Monitor backend logs for proper `is_premium` updates
- [ ] Test subscription cancellation per user
- [ ] Verify family sharing doesn't cause cross-contamination

## 🔧 **Development Tips**

### Clear RevenueCat State
If testing gets confused, clear RevenueCat state:

```dart
// In debug builds only
await Purchases.logOut();
// Then restart app
```

### Test User IDs
Use clear, distinct user IDs for testing:
- `test_user_1@example.com`
- `test_user_2@example.com`

### Monitor Network Traffic
Use tools like Charles Proxy to monitor:
- RevenueCat API calls
- Your backend API calls
- Apple StoreKit requests

## 📝 **Test Results Template**

```
Test Date: ___________
App Version: _________
RevenueCat SDK Version: _________

Test 1 - Basic User Isolation:
- User A Premium: [ PASS / FAIL ]
- User B Non-Premium: [ PASS / FAIL ]
- Backend Sync: [ PASS / FAIL ]

Test 2 - Purchase Attempt:
- Apple Dialog Appears: [ PASS / FAIL ]
- Independent Purchase: [ PASS / FAIL ]
- Separate Entitlements: [ PASS / FAIL ]

Test 3 - Cross-User Check:
- Different Customer IDs: [ PASS / FAIL ]
- No Entitlement Leakage: [ PASS / FAIL ]

Test 4 - Device Switching:
- User A Multi-Device: [ PASS / FAIL ]
- User B Isolation: [ PASS / FAIL ]

Notes:
_________________________________
_________________________________
```

## 🎯 **Success Criteria**

The fix is successful when:

1. ✅ Each app user has completely separate RevenueCat customer records
2. ✅ Subscriptions don't carry over between users on same device
3. ✅ Premium status updates only happen after entitlement validation
4. ✅ Backend `is_premium` field accurately reflects current user's status
5. ✅ Multiple users can purchase independently on same device
6. ✅ Restore purchases works correctly per user 