const admin = require('firebase-admin');
const https = require('https');
const http = require('http');
const fs = require('fs');

// Initialize Firebase Admin
// Make sure you have serviceAccountKey.json in the same directory
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'pinksnap-mobile-app.appspot.com'
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

// Download image from URL
function downloadImage(url, filename) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;
    const file = fs.createWriteStream(filename);
    
    const request = protocol.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      }
    }, (response) => {
      // Handle redirects
      if (response.statusCode === 301 || response.statusCode === 302) {
        downloadImage(response.headers.location, filename)
          .then(resolve)
          .catch(reject);
        return;
      }
      
      if (response.statusCode !== 200) {
        reject(new Error(`Failed to download: ${response.statusCode}`));
        return;
      }
      
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve(filename);
      });
    });
    
    request.on('error', (err) => {
      fs.unlink(filename, () => {});
      reject(err);
    });
  });
}

// Upload image to Firebase Storage and get public URL
async function uploadToStorage(localPath, storagePath) {
  try {
    await bucket.upload(localPath, {
      destination: storagePath,
      metadata: {
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=31536000',
      },
      public: true, // Make file publicly accessible
    });
    
    const file = bucket.file(storagePath);
    
    // Make the file public
    await file.makePublic();
    
    // Get public URL
    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;
    
    return publicUrl;
  } catch (error) {
    console.error(`Upload error: ${error.message}`);
    throw error;
  }
}

// List all Pinterest URLs that need manual download
async function listPinterestImages() {
  console.log('📋 Listing all Pinterest image URLs...\n');
  
  const productsSnapshot = await db.collection('products').get();
  const pinterestProducts = [];
  
  for (const doc of productsSnapshot.docs) {
    const product = doc.data();
    const productId = doc.id;
    
    if (!product.images || product.images.length === 0) continue;
    
    const pinterestUrls = product.images.filter(url => 
      url.includes('pinimg.com') || url.includes('pinterest.com')
    );
    
    if (pinterestUrls.length > 0) {
      pinterestProducts.push({
        id: productId,
        name: product.name,
        urls: pinterestUrls
      });
    }
  }
  
  if (pinterestProducts.length === 0) {
    console.log('✅ No Pinterest images found!');
    return;
  }
  
  console.log(`Found ${pinterestProducts.length} products with Pinterest images:\n`);
  
  pinterestProducts.forEach((product, index) => {
    console.log(`${index + 1}. ${product.name} (ID: ${product.id})`);
    product.urls.forEach((url, i) => {
      console.log(`   Image ${i + 1}: ${url}`);
    });
    console.log('');
  });
  
  console.log('\n⚠️  Pinterest URLs cannot be automatically downloaded due to CORS.');
  console.log('📥 Please manually download these images and upload to Firebase Storage.');
  console.log('💡 Then run: node update-product-images.js <productId> <imageIndex> <newUrl>');
}

// Main migration function
async function migrateProductImages() {
  console.log('🚀 Starting automated image migration...\n');
  console.log('⚠️  Note: Pinterest images will be listed for manual migration.\n');
  
  const productsSnapshot = await db.collection('products').get();
  let migrated = 0;
  let skipped = 0;
  let failed = 0;
  
  for (const doc of productsSnapshot.docs) {
    const product = doc.data();
    const productId = doc.id;
    
    console.log(`\n📦 Processing: ${product.name} (${productId})`);
    
    if (!product.images || product.images.length === 0) {
      console.log('   ⚠️  No images found');
      skipped++;
      continue;
    }
    
    const newImageUrls = [];
    let productUpdated = false;
    
    for (let i = 0; i < product.images.length; i++) {
      const imageUrl = product.images[i];
      
      // Skip if already on Firebase Storage
      if (imageUrl.includes('firebasestorage.googleapis.com') || 
          imageUrl.includes('storage.googleapis.com')) {
        console.log(`   ✅ Image ${i + 1} already on Firebase Storage`);
        newImageUrls.push(imageUrl);
        continue;
      }
      
      // Skip Pinterest URLs - they need manual download
      if (imageUrl.includes('pinimg.com') || imageUrl.includes('pinterest.com')) {
        console.log(`   ⚠️  Image ${i + 1} is from Pinterest - skipping (manual download required)`);
        newImageUrls.push(imageUrl);
        skipped++;
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
        console.log(`      New URL: ${newUrl}`);
        migrated++;
        productUpdated = true;
        
      } catch (error) {
        console.log(`   ❌ Failed to migrate image ${i + 1}: ${error.message}`);
        newImageUrls.push(imageUrl); // Keep old URL
        failed++;
      }
    }
    
    // Update product document if any images were migrated
    if (productUpdated) {
      await doc.ref.update({ images: newImageUrls });
      console.log(`   💾 Updated product document`);
    }
  }
  
  console.log('\n\n📊 Migration Summary:');
  console.log(`   ✅ Migrated: ${migrated} images`);
  console.log(`   ⚠️  Skipped: ${skipped} images (Pinterest or already migrated)`);
  console.log(`   ❌ Failed: ${failed} images`);
  console.log('\n✨ Migration complete!');
  console.log('\n📋 Run "node migrate-images.js --list" to see Pinterest URLs that need manual migration.');
}

// Parse command line arguments
const args = process.argv.slice(2);

if (args.includes('--list') || args.includes('-l')) {
  listPinterestImages()
    .then(() => process.exit(0))
    .catch(error => {
      console.error('Error:', error);
      process.exit(1);
    });
} else {
  migrateProductImages()
    .then(() => process.exit(0))
    .catch(error => {
      console.error('Error:', error);
      process.exit(1);
    });
}
