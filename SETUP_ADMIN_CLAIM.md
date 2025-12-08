# 🔧 Setting Admin Custom Claim - Step by Step

## What You Need

From your logs, we know:
- **Admin Email**: `admin@pinksnap1.com`
- **Admin UID**: `F8WAmOj9trhqw0atmaYVk58n8d03`
- **Current Status**: Admin claim is `null` (not set)
- **Goal**: Set admin claim to `true`

---

## Steps

### 1. Download Service Account Key

1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project (should match `pinksnap-mobile-app`)
3. Click the ⚙️ gear icon → **Project settings**
4. Go to **Service accounts** tab
5. Click **"Generate new private key"**
6. Click **"Generate key"** in the popup
7. Save the downloaded JSON file as `serviceAccountKey.json` in this project folder

⚠️ **IMPORTANT**: Keep this file private! Don't commit it to Git!

---

### 2. Install Dependencies

Open terminal in this project folder and run:

```bash
npm install
```

This installs `firebase-admin` package.

---

### 3. Run the Admin Claim Script

```bash
node set-admin-claim.js F8WAmOj9trhqw0atmaYVk58n8d03
```

You should see:
```
✅ Firebase Admin SDK initialized
   Project ID: pinksnap-mobile-app
   
🔄 Setting admin claim for: F8WAmOj9trhqw0atmaYVk58n8d03 (UID)

✅ Found user: admin@pinksnap1.com (UID: F8WAmOj9trhqw0atmaYVk58n8d03)

✅ SUCCESS! Admin claim set for UID: F8WAmOj9trhqw0atmaYVk58n8d03
   Email: admin@pinksnap1.com
```

---

### 4. Sign Out and Sign In

1. Open your Flutter app
2. **Sign out** from the admin account
3. **Sign in** again with `admin@pinksnap1.com`

This forces a token refresh with the new custom claim.

---

### 5. Verify in Logs

After signing in, check the Flutter console logs. You should see:

```
🔐 Token Claims for admin@pinksnap1.com:
   - admin claim: true    ← This should now be TRUE!
   - all claims: {..., admin: true, ...}

🔐 Admin claim in auth listener: true
User role from Firestore: UserRole.admin
```

---

### 6. Test Order Status Update

1. Go to admin panel in the app
2. Find an order
3. Update its status
4. You should **NOT** see this error anymore:
   ```
   ❌ [cloud_firestore/permission-denied]
   ```

5. Instead, you should see:
   ```
   ✅ Status update notification sent for order abc12345
   ```

---

## Troubleshooting

### ❌ Error: "Cannot find module 'firebase-admin'"

**Solution**: Run `npm install` in this folder

### ❌ Error: "Cannot find module './serviceAccountKey.json'"

**Solution**: 
- Download the service account key from Firebase Console
- Make sure it's named exactly `serviceAccountKey.json`
- Place it in the same folder as `set-admin-claim.js`

### ❌ Admin claim still shows `null` in logs

**Solutions**:
1. **Did you sign out and back in?** Old tokens are cached!
2. **Check project_id in serviceAccountKey.json** - should be `pinksnap-mobile-app`
3. **Verify script ran successfully** - look for "✅ SUCCESS!" message
4. **Check you used the correct UID** - should be `F8WAmOj9trhqw0atmaYVk58n8d03`

### ❌ Still getting PERMISSION_DENIED after admin claim is true

**Solutions**:
1. **Verify Firestore rules are deployed**:
   - Go to Firebase Console → Firestore Database → Rules
   - Check for `function isAdmin()` at the top
   - Check for notifications rule with `allow create: if isAdmin();`
   
2. **Deploy rules manually**:
   ```bash
   firebase deploy --only firestore:rules
   ```

---

## Files You'll Need

- ✅ `serviceAccountKey.json` (download from Firebase)
- ✅ `set-admin-claim.js` (already in project)
- ✅ `package.json` (already in project)
- ✅ `firestore.rules` (already updated)

---

## Quick Command Reference

```bash
# Install dependencies
npm install

# Set admin claim by UID (recommended)
node set-admin-claim.js F8WAmOj9trhqw0atmaYVk58n8d03

# Set admin claim by email (alternative)
node set-admin-claim.js admin@pinksnap1.com

# Deploy Firestore rules
firebase deploy --only firestore:rules
```

---

## Security Notes

🔒 **Never commit `serviceAccountKey.json` to Git!**

Add to `.gitignore`:
```
serviceAccountKey.json
node_modules/
```

🔒 **Keep service account keys secure** - they have full admin access to your Firebase project!

---

## After Setup

Once everything works:

1. ✅ Admin can update order status
2. ✅ Notifications are created successfully  
3. ✅ No PERMISSION_DENIED errors
4. ✅ Logs show `admin claim: true`

You're done! 🎉

---

**Need help?** Check `ADMIN_SETUP_GUIDE.md` for detailed troubleshooting.
