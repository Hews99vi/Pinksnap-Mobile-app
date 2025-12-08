# 🚀 QUICK FIX DEPLOYMENT STEPS

## Issue Fixed
❌ **Before**: `PERMISSION_DENIED` when admin updates order status  
✅ **After**: Admin can update orders and create notifications

---

## Step 1: Deploy Firestore Rules (REQUIRED)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to: **Firestore Database** → **Rules**
4. Copy the contents from `firestore.rules` in this project
5. Paste into the Firebase Console rules editor
6. Click **"Publish"**

**OR** use Firebase CLI:
```bash
firebase deploy --only firestore:rules
```

---

## Step 2: Set Admin Custom Claim (REQUIRED)

Choose one method:

### Method A: Using the provided script (Easiest)

1. Download service account key:
   - Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save as `serviceAccountKey.json` in project root

2. Install dependencies and run:
   ```bash
   npm install
   node set-admin-claim.js F8WAmOj9trhqw0atmaYVk58n8d03
   ```
   
   Or use email:
   ```bash
   node set-admin-claim.js admin@pinksnap1.com
   ```

### Method B: Using Firebase CLI directly

```bash
firebase functions:shell
admin.auth().getUserByEmail('admin@pinksnap1.com').then(u => admin.auth().setCustomUserClaims(u.uid, {admin: true}))
```

### Method C: Manual using Firebase Admin SDK

See `ADMIN_SETUP_GUIDE.md` for detailed instructions.

---

## Step 3: Test the Fix

1. **Sign out** from the admin account
2. **Sign in** again (important - refreshes token)
3. Check Flutter logs for:
   ```
   🔐 Token Claims for admin@pinksnap1.com:
      - admin claim: true
   ```
4. Try updating an order status
5. Check logs - should NOT see permission errors

---

## Verification Checklist

- [ ] Firestore rules deployed successfully
- [ ] Admin custom claim set for admin user(s)
- [ ] Admin signed out and back in
- [ ] Token claims show `admin: true` in logs
- [ ] Order status updates work without errors
- [ ] Notifications are created successfully
- [ ] No `PERMISSION_DENIED` errors in console

---

## Expected Log Output (Success)

```
I/flutter: 🔐 Token Claims for admin@pinksnap1.com:
I/flutter:    - admin claim: true
I/flutter: 🔐 Admin claim in auth listener: true
I/flutter: User role from Firestore: UserRole.admin
I/flutter: Status update notification sent for order abc12345
```

---

## Still Getting Errors?

### 1. Check admin claim in logs:
Look for this in Flutter console after login:
```
🔐 Token Claims for admin@pinksnap1.com:
   - admin claim: true    ← Should be TRUE, not null
```

If it shows `null`:
- Admin claim was NOT set successfully
- Re-run the `set-admin-claim.js` script
- Verify you're using the correct UID: `F8WAmOj9trhqw0atmaYVk58n8d03`
- Check `project_id` in `serviceAccountKey.json` matches your Firebase project

### 2. Force token refresh in app:
The user MUST sign out and sign back in after setting the claim.
The app already does this automatically on login, but you can verify:
```dart
final token = await FirebaseAuth.instance.currentUser?.getIdTokenResult(true);
debugPrint('Admin? ${token?.claims?['admin']}');
```

### 3. Verify rules are deployed:
- Check Firebase Console → Firestore Database → Rules
- Look for `function isAdmin()` at the top
- Look for `match /notifications/{notificationId}` rule
- Check the timestamp - rules should be recently published

### 4. Check you're using the right Firebase project:
```bash
firebase projects:list
firebase use <project-id>
```

### 5. Temporary workaround (DEV ONLY):
If you need it working NOW while debugging, temporarily change the rule:
```javascript
match /notifications/{notificationId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;  // ⚠️ ANY authenticated user
  allow update, delete: if false;
}
```
Deploy this, and the error will stop. **IMPORTANT**: Revert to `isAdmin()` check before production!

---

## Files Modified

✅ `firestore.rules` - Added admin helper and notifications rules  
✅ `lib/services/firebase_auth_service.dart` - Token refresh + debug logs  
✅ `lib/controllers/auth_controller.dart` - Token refresh in auth listener  
📄 `ADMIN_SETUP_GUIDE.md` - Detailed setup instructions  
📄 `set-admin-claim.js` - Admin claim setup script  
📄 `package.json` - Dependencies for admin script  

---

## Need Help?

1. Check `ADMIN_SETUP_GUIDE.md` for detailed troubleshooting
2. Ensure all steps above are completed in order
3. Look for the 🔐 emoji in logs to verify token claims
4. Confirm user signed out/in after setting admin claim

---

**Last Updated**: December 8, 2025
