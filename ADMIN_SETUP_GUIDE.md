# Admin Setup Guide - Firebase Custom Claims

## Problem Fixed
Admin users were getting `PERMISSION_DENIED` errors when updating order status because they couldn't write to the `notifications` collection.

## Solution Implemented

### 1. Updated Firestore Security Rules ✅
- Added `isAdmin()` helper function that checks for `admin` custom claim
- Added notifications collection rules:
  ```
  allow read: if authenticated and (isAdmin or owns notification)
  allow create: if isAdmin
  allow update, delete: if false
  ```

### 2. Updated Flutter Code ✅
- Added token refresh in `signInWithEmailAndPassword()` to get latest custom claims
- Added debug logging to display admin claim status
- Token refresh also added in auth state listener

## Required: Set Admin Custom Claim in Firebase

**IMPORTANT:** You must set the admin custom claim in Firebase Console or using Firebase Admin SDK.

### Option A: Using Firebase Console (Easy)

Firebase Console doesn't have a direct UI for custom claims. Use Option B or C instead.

### Option B: Using Firebase CLI (Recommended)

1. Install Firebase CLI if not already installed:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Create a script `set-admin-claim.js`:
   ```javascript
   const admin = require('firebase-admin');
   const serviceAccount = require('./path-to-your-service-account-key.json');

   admin.initializeApp({
     credential: admin.credential.cert(serviceAccount)
   });

   const email = 'admin@pinksnap1.com'; // Your admin email

   admin.auth().getUserByEmail(email)
     .then((user) => {
       return admin.auth().setCustomUserClaims(user.uid, { admin: true });
     })
     .then(() => {
       console.log(`✅ Admin claim set for ${email}`);
       process.exit(0);
     })
     .catch((error) => {
       console.error('❌ Error:', error);
       process.exit(1);
     });
   ```

4. Run the script:
   ```bash
   node set-admin-claim.js
   ```

### Option C: Using Cloud Functions (Production Ready)

Create a Cloud Function to set admin claims:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.setAdminClaim = functions.https.onCall(async (data, context) => {
  // Only allow existing admins to create new admins
  if (context.auth.token.admin !== true) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can set admin claims'
    );
  }

  const { email } = data;
  const user = await admin.auth().getUserByEmail(email);
  
  await admin.auth().setCustomUserClaims(user.uid, { admin: true });
  
  return { 
    message: `Admin claim set for ${email}`,
    success: true 
  };
});
```

### Option D: Quick Test (Development Only)

For testing, you can temporarily modify Firestore rules to allow all authenticated users to create notifications:

```javascript
match /notifications/{notificationId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null; // ⚠️ TESTING ONLY
  allow update, delete: if false;
}
```

**⚠️ WARNING:** Revert this after testing! All users could create notifications.

## Verifying Admin Claim

After setting the admin claim:

1. **User must sign out and sign in again** (important!)
2. Check the Flutter logs for:
   ```
   🔐 Token Claims for admin@pinksnap1.com:
      - admin claim: true
      - all claims: {admin: true, ...}
   ```

3. Try updating an order status - notifications should now work without permission errors

## Quick Check Script

Add this to your admin login success handler for debugging:

```dart
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final idTokenResult = await user.getIdTokenResult(true);
  debugPrint('Admin claim: ${idTokenResult.claims?['admin']}');
  
  if (idTokenResult.claims?['admin'] != true) {
    debugPrint('⚠️ WARNING: Admin claim is not set for this user!');
  }
}
```

## Troubleshooting

### Still getting PERMISSION_DENIED?

1. **Check admin claim is set:**
   - Look for `🔐 Admin claim in auth listener: true` in logs
   - If it shows `null` or `false`, the claim isn't set

2. **Ensure user signed out and back in:**
   - Custom claims only refresh on new sign-in or token refresh
   - Force refresh: `await FirebaseAuth.instance.currentUser?.getIdToken(true);`

3. **Verify Firestore rules are deployed:**
   - Go to Firebase Console → Firestore Database → Rules
   - Check that the `isAdmin()` helper and notifications rules are present
   - Click "Publish" if rules show as unpublished

4. **Check Firebase project:**
   - Ensure you're testing in the correct Firebase project
   - Verify the rules are deployed to the right environment

### Error: "Sign in required after claim update"

This is expected! Custom claims are embedded in the auth token. After setting claims:
1. User must sign out
2. User must sign in again
3. Token will contain the new claims

## Production Deployment Checklist

- [ ] Set admin custom claim for admin users using Option B or C
- [ ] Deploy updated Firestore rules to production
- [ ] Test admin login and order status updates
- [ ] Verify notifications are created successfully
- [ ] Remove any temporary testing rules
- [ ] Document admin users in a secure location

## Files Modified

1. `firestore.rules` - Added isAdmin() helper and notifications rules
2. `lib/services/firebase_auth_service.dart` - Added token refresh and debug logging
3. `lib/controllers/auth_controller.dart` - Added token refresh in auth listener

## Expected Behavior After Fix

✅ Admin logs in → Token refreshed with admin claim
✅ Admin updates order status → Order updated successfully  
✅ System creates notification → Notification written to Firestore
✅ No permission errors in console

## Need Help?

If you're still experiencing issues:
1. Share the full error logs including the 🔐 token claims output
2. Confirm which option you used to set admin claims
3. Verify you logged out and back in after setting claims
