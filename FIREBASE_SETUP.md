# Firebase Setup Guide for PinkSnap Mobile

This guide will help you set up Firebase for your Flutter project.

## Prerequisites

1. **Flutter SDK** - Make sure you have Flutter installed
2. **Firebase CLI** - Install Firebase CLI tools
3. **Google Account** - You'll need a Google account to access Firebase

## Step 1: Install Firebase CLI

### Windows (PowerShell)
```powershell
# Install Firebase CLI using npm (if you have Node.js)
npm install -g firebase-tools

# Or download the standalone binary from Firebase website
# https://firebase.google.com/docs/cli#install-cli-windows
```

### Alternative: Use FlutterFire CLI
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

## Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name (e.g., "pinksmapmobile")
4. Enable Google Analytics (optional but recommended)
5. Choose your Google Analytics account
6. Click "Create project"

## Step 3: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click **Get started**
3. Go to **Sign-in method** tab
4. Enable **Email/Password** provider
5. Click **Save**

## Step 4: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location closest to your users
5. Click **Done**

## Step 5: Configure Flutter App

### Using FlutterFire CLI (Recommended)

1. Login to Firebase:
```bash
firebase login
```

2. Navigate to your project directory:
```bash
cd path/to/your/flutter/project
```

3. Configure Firebase for your Flutter app:
```bash
flutterfire configure
```

4. Select your Firebase project
5. Select platforms (Android, iOS, Web, etc.)
6. This will automatically generate `firebase_options.dart` file

### Manual Configuration

If you prefer manual setup, you'll need to:

1. **For Android:**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/` directory
   - Add Firebase SDK to `android/app/build.gradle`

2. **For iOS:**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add it to iOS project in Xcode

3. **Update firebase_options.dart:**
   - Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration

## Step 6: Set up Firestore Security Rules

In Firebase Console > Firestore Database > Rules, use these initial rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Everyone can read products, only admins can write
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users can read/write their own cart
    match /carts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read/write their own wishlist
    match /wishlists/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read/write their own orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Everyone can read categories
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Step 7: Test the Setup

1. Run your Flutter app:
```bash
flutter run
```

2. Try to register a new user
3. Check Firebase Console to see if the user was created in Authentication and Firestore

## Database Structure

Your Firestore database will have the following collections:

### `users`
```json
{
  "id": "user_id",
  "name": "User Name",
  "email": "user@example.com",
  "phoneNumber": "+1234567890",
  "role": "customer", // or "admin"
  "addresses": []
}
```

### `products`
```json
{
  "id": "product_id",
  "name": "Product Name",
  "description": "Product description",
  "price": 99.99,
  "images": ["url1", "url2"],
  "category": "Category Name",
  "sizes": ["S", "M", "L"],
  "stock": {"S": 10, "M": 15, "L": 8},
  "rating": 4.5,
  "reviewCount": 100
}
```

### `carts`
```json
{
  "userId": {
    "items": [
      {
        "productId": "product_id",
        "productName": "Product Name",
        "price": 99.99,
        "size": "M",
        "quantity": 2,
        "productImage": "image_url"
      }
    ],
    "updatedAt": "timestamp"
  }
}
```

### `wishlists`
```json
{
  "userId": {
    "productIds": ["product_id1", "product_id2"],
    "updatedAt": "timestamp"
  }
}
```

## Troubleshooting

1. **Build errors**: Make sure you've run `flutter pub get` after adding Firebase dependencies
2. **Authentication errors**: Check if you've enabled Email/Password in Firebase Console
3. **Permission denied**: Verify your Firestore security rules
4. **Configuration errors**: Make sure `firebase_options.dart` has correct values

## Sample Data

To add sample data to your Firestore database, you can use the Firebase Console or create a script. Here's an example of adding sample products:

```json
// Sample product in Firestore
{
  "name": "Summer Dress",
  "description": "Beautiful summer dress perfect for any occasion",
  "price": 59.99,
  "images": ["https://example.com/image1.jpg"],
  "category": "Dresses",
  "sizes": ["XS", "S", "M", "L", "XL"],
  "stock": {"XS": 5, "S": 10, "M": 15, "L": 8, "XL": 3},
  "rating": 4.5,
  "reviewCount": 124
}
```

## Security Notes

- Never commit your `google-services.json` or `GoogleService-Info.plist` files to version control
- Use environment variables for sensitive configuration in production
- Regularly review and update your Firestore security rules
- Enable App Check for production apps to prevent abuse

For more detailed information, visit the [Official Firebase Documentation](https://firebase.google.com/docs/flutter/setup).
