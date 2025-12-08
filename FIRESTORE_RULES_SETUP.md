# Firestore Rules Setup

## 🚀 Quick Setup for New Machines

When you clone this repo to a new machine, you need to deploy the Firestore rules to your Firebase project.

### Steps:

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com
   - Select your project: `pinksnap-mobile-app`

2. **Navigate to Firestore Rules**
   - Click: **Firestore Database** (left sidebar)
   - Click: **Rules** tab

3. **Deploy the Rules**
   - Copy the entire content from `firestore.rules` file
   - Paste it into the Firebase Console Rules editor
   - Click: **Publish**

### ✅ How It Works

The rules use **Firestore role-based authentication**:

```dart
function isAdmin() {
  return request.auth != null
      && exists(/databases/$(database)/documents/users/$(request.auth.uid))
      && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
}
```

This checks the `role` field in the user's Firestore document (`users/{uid}`), NOT custom claims.

### 📋 Admin User Setup

For a user to be admin, ensure their document in `users` collection has:

```json
{
  "role": "admin",
  "email": "admin@pinksnap1.com",
  "name": "Admin User"
}
```

### ⚠️ Important Notes

- **No Node.js scripts needed**: The rules use Firestore data, not custom claims
- **No backend setup**: Everything works through Firestore security rules
- **No sign out/sign in needed**: Rules check real-time data from Firestore
- The admin role is already set in Firestore for `admin@pinksnap1.com`

### 🧪 Testing

After deploying rules:

1. Sign in as admin (`admin@pinksnap1.com`)
2. Update any order status in admin panel
3. Should see: `"Status update notification sent for order xxx"` in console
4. Should NOT see: `PERMISSION_DENIED` errors

### 🔧 Troubleshooting

If you see `PERMISSION_DENIED` when admin updates orders:

1. Verify rules are deployed correctly (check Firebase Console)
2. Verify admin user has `role: "admin"` in Firestore `users` collection
3. Check console logs for: `"User {uid} is admin: true"`

---

**Related Files:**
- `firestore.rules` - Main rules file (deploy this)
- `firestore.rules.clean` - Clean version without comments (same content)
- `lib/controllers/order_controller.dart` - Order management & notifications
