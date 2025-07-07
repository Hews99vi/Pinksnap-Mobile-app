## Quick Fix for Firestore Permission Error

**The error you're seeing is due to Firestore security rules not allowing writes to the 'orders' collection.**

### **Immediate Solutions:**

#### **Option 1: Update Firestore Rules (Recommended)**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Firestore Database** → **Rules**
4. Replace the existing rules with this **temporary testing rule**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // TEMPORARY: Allow all reads and writes for testing
    // IMPORTANT: Change this before going to production!
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

5. Click **"Publish"**

#### **Option 2: Production-Ready Rules**
For a more secure approach, use these rules instead:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Orders: Allow anyone to create, admins to manage
    match /orders/{orderId} {
      allow create: if true; // Allow guest checkout
      allow read, update, delete: if request.auth != null && 
        (request.auth.token.isAdmin == true || 
         request.auth.uid == resource.data.userId);
    }
    
    // Products: Read for all, write for admins
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.isAdmin == true;
    }
    
    // Users: Users can manage their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == userId || request.auth.token.isAdmin == true);
    }
  }
}
```

### **After updating the rules:**
1. Try placing an order again
2. The error should be resolved
3. Orders will be saved to Firestore
4. Admin panel will show real order data

### **If you still get errors:**
- Check the Debug Console for detailed error messages
- Ensure your Firebase project is properly connected
- Verify the `google-services.json` file is in the correct location

The debugging I added will show detailed logs in the console to help identify any remaining issues.
