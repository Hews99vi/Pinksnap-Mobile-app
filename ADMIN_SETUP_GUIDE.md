# Admin Panel Access Setup Guide

To properly set up the admin panel in your PinkSnap Mobile app, you need to configure Firebase Authentication and Firestore security rules correctly.

## 1. Issue with Admin Orders Access

If you're seeing the error:
```
Error: Failed to load orders: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

This means your current user doesn't have admin privileges according to the Firestore security rules.

## 2. How to Fix It

There are two approaches to fix this issue:

### Option A: Firebase Custom Claims (Recommended)

This approach requires a backend or Firebase Cloud Function:

1. **Set up a Cloud Function to assign admin rights**:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.addAdminRole = functions.https.onCall((data, context) => {
  // Check if request is made by an admin
  if (context.auth.token.admin !== true) {
    return { error: 'Only admins can add other admins' };
  }
  
  // Get user and add custom claim (admin)
  return admin.auth().getUserByEmail(data.email).then(user => {
    return admin.auth().setCustomUserClaims(user.uid, {
      admin: true
    });
  }).then(() => {
    return {
      message: `Success! ${data.email} has been made an admin.`
    };
  }).catch(err => {
    return { error: err };
  });
});
```

2. **Call this function for your admin user's email**

### Option B: Create an Admin Document (Quick Solution)

For immediate testing, you can create an admin document in Firestore:

1. Go to Firebase Console > Firestore Database
2. Create a new collection called `admins`
3. Add a document with the ID matching your user's UID
4. Add fields: `{ role: "admin", email: "your-admin-email@example.com" }`

### Option C: Temporary Development Mode (NOT for production)

For quick testing only:

1. Update your firestore.rules file
2. Uncomment the development section:
```
match /{document=**} {
  allow read, write: if true;
}
```
3. Publish the rules

## 3. Updating Your App Code

The fixes applied to your code include:

1. Better error handling in the OrderController to detect permission errors
2. User-friendly error messages in the Admin Orders screen
3. Proper admin permission checking before attempting to load all orders
4. Fallback to user's own orders when admin access fails

## 4. Next Steps

1. Replace the contents of your `firestore.rules` file with the contents of `firestore.rules.updated`
2. Set up proper admin authentication using one of the methods above
3. Test the admin panel access again

## 5. Checking Admin Status in App

You can add this debug function to check if a user has admin rights:

```dart
Future<void> checkAdminStatus() async {
  try {
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is logged in');
      return;
    }
    
    // Force refresh the token to get latest claims
    await user.getIdTokenResult(true).then((idTokenResult) {
      if (idTokenResult.claims?['admin'] == true) {
        print('Current user is an ADMIN');
      } else {
        print('Current user is NOT an admin');
      }
    });
    
    // Also check Firestore admins collection
    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.uid)
        .get();
    
    if (doc.exists) {
      print('User exists in admins collection: ${doc.data()}');
    } else {
      print('User does not exist in admins collection');
    }
  } catch (e) {
    print('Error checking admin status: $e');
  }
}
```
