# Pinterest Image Migration Issue

## ❌ Problem Identified

Your product images are hosted on **Pinterest (i.pinimg.com)**, which blocks external websites from loading their images due to:
- **CORS policy**: Pinterest doesn't allow cross-origin requests
- **Hotlinking protection**: Pinterest prevents direct embedding of images
- **Error**: `HTTP request failed, statusCode: 0`

### Examples from your logs:
- `https://i.pinimg.com/736x/08/1c/fd/081cfd619f09b87b37b3b02d75bc3ac2.jpg`
- `https://i.pinimg.com/1200x/d6/94/df/d694df5dab5a1a76d737110057070344.jpg`
- `https://i.pinimg.com/1200x/61/94/90/619490ffcfdd6bbc7fc82b99ce56fd30.jpg`

## ✅ Solution: Migrate to Firebase Storage

You need to **download these images and upload them to your own Firebase Storage**.

### Option 1: Manual Migration (Small scale)

#### Step 1: Download Images
1. Open each Pinterest URL in browser
2. Right-click → Save Image As
3. Save to a folder (e.g., `product-images/`)

#### Step 2: Upload to Firebase Storage
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project: `pinksnap-mobile-app`
3. Click **Storage** → **Files**
4. Create folder: `products/`
5. Upload all images to this folder

#### Step 3: Update Firestore URLs
1. Go to **Firestore Database**
2. Find each product document
3. Update the `images` array with new Firebase Storage URLs
4. New URLs will look like:
   ```
   https://firebasestorage.googleapis.com/v0/b/pinksnap-mobile-app.appspot.com/o/products%2Fproduct-name.jpg?alt=media&token=...
   ```

### Option 2: Automated Migration Script (Recommended)

Create a Node.js script to automate the process:

```javascript
// migrate-images.js
const admin = require('firebase-admin');
const https = require('https');
const http = require('http');
const { URL } = require('url');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'pinksnap-mobile-app.appspot.com'
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

// Download image from URL
async function downloadImage(url, filename) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;
    const file = fs.createWriteStream(filename);
    
    protocol.get(url, (response) => {
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve(filename);
      });
    }).on('error', (err) => {
      fs.unlink(filename, () => {});
      reject(err);
    });
  });
}

// Upload image to Firebase Storage
async function uploadToStorage(localPath, storagePath) {
  await bucket.upload(localPath, {
    destination: storagePath,
    metadata: {
      contentType: 'image/jpeg',
      cacheControl: 'public, max-age=31536000',
    }
  });
  
  const file = bucket.file(storagePath);
  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: '03-01-2500'
  });
  
  return url;
}

// Main migration function
async function migrateProductImages() {
  console.log('🚀 Starting image migration...');
  
  const productsSnapshot = await db.collection('products').get();
  let migrated = 0;
  let failed = 0;
  
  for (const doc of productsSnapshot.docs) {
    const product = doc.data();
    const productId = doc.id;
    
    console.log(`\n📦 Processing: ${product.name} (${productId})`);
    
    if (!product.images || product.images.length === 0) {
      console.log('   ⚠️  No images found');
      continue;
    }
    
    const newImageUrls = [];
    
    for (let i = 0; i < product.images.length; i++) {
      const imageUrl = product.images[i];
      
      // Skip if already on Firebase Storage
      if (imageUrl.includes('firebasestorage.googleapis.com')) {
        console.log(`   ✅ Image ${i + 1} already on Firebase Storage`);
        newImageUrls.push(imageUrl);
        continue;
      }
      
      // Skip if Pinterest URL (can't download due to CORS)
      if (imageUrl.includes('pinimg.com')) {
        console.log(`   ❌ Image ${i + 1} is from Pinterest - MANUAL DOWNLOAD REQUIRED`);
        console.log(`      URL: ${imageUrl}`);
        failed++;
        newImageUrls.push(imageUrl); // Keep old URL for now
        continue;
      }
      
      try {
        // Download image
        const tempPath = `./temp-${productId}-${i}.jpg`;
        console.log(`   ⬇️  Downloading image ${i + 1}...`);
        await downloadImage(imageUrl, tempPath);
        
        // Upload to Firebase Storage
        const storagePath = `products/${productId}-${i}.jpg`;
        console.log(`   ⬆️  Uploading to Firebase Storage...`);
        const newUrl = await uploadToStorage(tempPath, storagePath);
        
        // Clean up temp file
        fs.unlinkSync(tempPath);
        
        newImageUrls.push(newUrl);
        console.log(`   ✅ Image ${i + 1} migrated successfully`);
        migrated++;
        
      } catch (error) {
        console.log(`   ❌ Failed to migrate image ${i + 1}: ${error.message}`);
        newImageUrls.push(imageUrl); // Keep old URL
        failed++;
      }
    }
    
    // Update product document if any images were migrated
    if (newImageUrls.some((url, i) => url !== product.images[i])) {
      await doc.ref.update({ images: newImageUrls });
      console.log(`   💾 Updated product document`);
    }
  }
  
  console.log('\n\n📊 Migration Summary:');
  console.log(`   ✅ Migrated: ${migrated} images`);
  console.log(`   ❌ Failed: ${failed} images`);
  console.log('\n✨ Migration complete!');
}

// Run migration
migrateProductImages().catch(console.error);
```

**To use this script:**

```bash
# Install dependencies
npm install firebase-admin

# Run migration
node migrate-images.js
```

### Option 3: Quick Fix - Use Placeholder or Stock Images

For testing purposes, you can temporarily use placeholder images:

1. Upload a few generic placeholder images to Firebase Storage
2. Update products to use these placeholders
3. Later, replace with actual product images

### Option 4: Use CORS Proxy (Not Recommended for Production)

⚠️ **Only for testing**, not for production:

```dart
// In product_card.dart
final imageUrl = product.images.isNotEmpty 
    ? product.images[0]
    : '';

// Add CORS proxy for Pinterest images
final displayUrl = imageUrl.contains('pinimg.com')
    ? 'https://corsproxy.io/?' + Uri.encodeComponent(imageUrl)
    : imageUrl;

// Use displayUrl instead of imageUrl
```

## 🎯 Recommended Action Plan

### Immediate (Testing):
1. Upload 5-10 sample images to Firebase Storage manually
2. Update those product documents with new URLs
3. Test if images load correctly

### Short-term (Production):
1. Download ALL Pinterest images manually (or use script)
2. Upload to Firebase Storage via Firebase Console
3. Update all product documents with new URLs
4. Deploy storage.rules to allow public read access

### Long-term:
1. When adding new products, upload images directly to Firebase Storage
2. Don't use Pinterest URLs in production
3. Implement image upload in your admin panel

## 📝 Updated Storage Rules

Make sure your `storage.rules` allows public read:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /products/{fileName} {
      allow read: if true;  // Public read for product images
      allow write: if request.auth != null;  // Authenticated write
    }
  }
}
```

## 🔍 How to Find Which Products Need Migration

Run this query in Firebase Console → Firestore:

```javascript
// Find products with Pinterest images
db.collection('products')
  .get()
  .then(snapshot => {
    snapshot.docs.forEach(doc => {
      const data = doc.data();
      if (data.images && data.images.some(url => url.includes('pinimg.com'))) {
        console.log(`${doc.id}: ${data.name} - ${data.images[0]}`);
      }
    });
  });
```

## Summary

**Root Cause**: Pinterest blocks hotlinking/embedding of their images

**Solution**: Migrate images to Firebase Storage

**Quick Test**: Upload 1 image manually to Firebase Storage and update 1 product to verify the fix works

---

**The CORS configuration we created earlier is correct, but it only works for Firebase Storage URLs, not Pinterest URLs.**
