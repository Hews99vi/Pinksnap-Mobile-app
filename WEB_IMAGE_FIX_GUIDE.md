# Firebase Storage CORS Configuration Guide

## Problem
Product images are not loading in the **web version** of the app (showing placeholder icons). This is due to **CORS (Cross-Origin Resource Sharing)** restrictions on Firebase Storage.

## Root Cause
When Flutter web tries to load images from Firebase Storage, the browser blocks the requests because Firebase Storage doesn't allow cross-origin requests by default.

## Solution: Configure CORS on Firebase Storage

### Option 1: Using Google Cloud Console (Easiest - GUI Method)

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com
   - Select your project: `pinksnap-mobile-app`

2. **Navigate to Cloud Storage**
   - Click hamburger menu (☰) → **Cloud Storage** → **Buckets**
   - Find your Firebase Storage bucket (usually named like `pinksnap-mobile-app.appspot.com`)

3. **Configure CORS**
   - Click on the **bucket name**
   - Go to the **Permissions** tab
   - Click **Add** under CORS
   - Add this configuration:
     ```json
     [
       {
         "origin": ["*"],
         "method": ["GET", "HEAD"],
         "maxAgeSeconds": 3600
       }
     ]
     ```

4. **Save** the configuration

### Option 2: Using gsutil Command Line (Recommended)

#### Prerequisites
1. Install Google Cloud SDK: https://cloud.google.com/sdk/docs/install

2. Authenticate:
   ```bash
   gcloud auth login
   ```

3. Set your project:
   ```bash
   gcloud config set project pinksnap-mobile-app
   ```

#### Apply CORS Configuration

1. **Use the included cors.json file:**
   ```bash
   gsutil cors set cors.json gs://pinksnap-mobile-app.appspot.com
   ```

2. **Verify CORS configuration:**
   ```bash
   gsutil cors get gs://pinksnap-mobile-app.appspot.com
   ```

### Option 3: Using Firebase Console

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com
   - Select your project

2. **Open Cloud Storage**
   - Click **Storage** in left sidebar
   - Click on **Files** tab

3. **Note**: Direct CORS configuration is not available in Firebase Console. You need to use Google Cloud Console or gsutil instead.

## Verification

After applying CORS configuration:

1. **Clear browser cache** (Ctrl+Shift+Delete)
2. **Restart your Flutter web app**
3. **Check browser console** (F12) for any remaining CORS errors
4. **Refresh the products page** - images should now load

## What Changed in Code

### Updated `lib/widgets/product_card.dart`:

- ✅ Added platform-specific image loading
- ✅ Uses `Image.network` for web (better CORS handling)
- ✅ Uses `CachedNetworkImage` for mobile (better performance)
- ✅ Added detailed error logging
- ✅ Shows "Image unavailable" text on error

### Benefits:
- Web version now uses standard Image.network with proper error handling
- Mobile version continues using CachedNetworkImage for caching
- Better error messages in console for debugging
- Graceful fallback UI when images fail to load

## Troubleshooting

### Still seeing placeholder icons after CORS config?

1. **Check the bucket name:**
   ```bash
   gsutil ls
   ```
   Make sure you're using the correct bucket name.

2. **Check image URLs in Firestore:**
   - Go to Firebase Console → Firestore
   - Open a product document
   - Verify the `images` array contains valid URLs
   - URLs should start with: `https://firebasestorage.googleapis.com/`

3. **Check browser console (F12):**
   - Look for CORS errors
   - Look for 403 Forbidden errors
   - Look for network errors

4. **Try opening an image URL directly:**
   - Copy an image URL from the product data
   - Paste it in a new browser tab
   - If it doesn't load, the problem is with the file itself or permissions

5. **Verify Storage Rules:**
   - Go to Firebase Console → Storage → Rules
   - Make sure you have read access:
     ```
     rules_version = '2';
     service firebase.storage {
       match /b/{bucket}/o {
         match /{allPaths=**} {
           allow read: if true;  // Allow public read for product images
           allow write: if request.auth != null;
         }
       }
     }
     ```

## Expected Console Output

After fix, you should see:
- ✅ Images loading without errors
- ✅ No CORS errors in console
- ❌ If images fail: `"❌ Image load error for [product name]: [error details]"`

## Files Modified

1. **cors.json** - CORS configuration file
2. **lib/widgets/product_card.dart** - Updated image loading logic
3. **WEB_IMAGE_FIX_GUIDE.md** - This guide

## Quick Command Reference

```bash
# Set up Google Cloud SDK
gcloud auth login
gcloud config set project pinksnap-mobile-app

# Apply CORS configuration
gsutil cors set cors.json gs://pinksnap-mobile-app.appspot.com

# Verify configuration
gsutil cors get gs://pinksnap-mobile-app.appspot.com

# List all buckets
gsutil ls
```

## Alternative: Make Storage Rules Public

If CORS still doesn't work, ensure your Storage rules allow public read:

**Firebase Console → Storage → Rules:**

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

Click **Publish** after making changes.

---

**Note**: The `origin: ["*"]` in CORS config allows all domains. For production, you should restrict this to your actual domain:

```json
{
  "origin": ["https://yourdomain.com"],
  "method": ["GET", "HEAD"],
  "maxAgeSeconds": 3600
}
```
