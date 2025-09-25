# PinkSnap Web Setup Guide

This document outlines how to set up and deploy the web version of PinkSnap.

## Prerequisites

- Flutter SDK with web support enabled
- Firebase project configured with web app
- Stripe account (if using payments)

## Enabling Web Support

Web support is already enabled in this project. The necessary configuration files are:
- `web/index.html` - Main HTML file with Firebase and Stripe scripts
- `web/manifest.json` - Web app manifest with app metadata
- `web/icons/` - Directory containing app icons for web

## Running Web Locally

To run the web version locally:

```bash
# Make sure you have the latest Flutter
flutter upgrade

# Verify web support is enabled
flutter config --enable-web

# Run in web mode
flutter run -d chrome
```

## Building for Production

To build the web app for production:

```bash
flutter build web --release
```

This will create a build/web directory containing all necessary files for deployment.

## Firebase Web Configuration

Ensure your Firebase web app configuration in `lib/firebase_options.dart` is correct:

1. Go to the Firebase console
2. Select your project
3. Click on the web app icon (</>) to register a web app if not already done
4. Copy the Firebase config
5. Update the web configuration in firebase_options.dart

## Web Features and Limitations

### Working Features
- User authentication
- Product browsing
- Cart functionality
- Order history
- Image search

### Limitations
- Stripe payments require additional implementation for web
- Some platform-specific features may have reduced functionality on web

## Deployment Options

### Firebase Hosting

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Initialize Firebase in your project:
```bash
firebase init hosting
```

4. Choose the `build/web` directory as your public directory when prompted

5. Deploy to Firebase:
```bash
firebase deploy
```

### Other Hosting Options

You can also deploy to:
- GitHub Pages
- Netlify
- Vercel
- Any static hosting service

## Responsive Design

The app uses a responsive design system to adapt to different screen sizes:
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: > 900px

Update the breakpoints in `lib/config/app_config.dart` if needed.

## Web-Specific Code

When adding web-specific code, use the `kIsWeb` constant:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Web-specific code
} else {
  // Mobile-specific code
}
```

## Troubleshooting

### Firebase Authentication Issues
- Make sure you've enabled the required sign-in methods in Firebase Console
- Check that your domain is authorized in Firebase Console

### Cross-Origin Issues
- Enable CORS on your backend APIs
- For Firebase Storage, configure CORS settings