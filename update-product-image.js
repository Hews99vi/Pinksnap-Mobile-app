const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'pinksnap-mobile-app.appspot.com'
});

const db = admin.firestore();

// Update a specific product image URL
async function updateProductImage(productId, imageIndex, newUrl) {
  try {
    const productRef = db.collection('products').doc(productId);
    const productDoc = await productRef.get();
    
    if (!productDoc.exists) {
      console.log(`❌ Product ${productId} not found`);
      return;
    }
    
    const product = productDoc.data();
    const images = product.images || [];
    
    if (imageIndex < 0 || imageIndex >= images.length) {
      console.log(`❌ Invalid image index ${imageIndex}. Product has ${images.length} images.`);
      return;
    }
    
    const oldUrl = images[imageIndex];
    images[imageIndex] = newUrl;
    
    await productRef.update({ images });
    
    console.log(`✅ Updated product: ${product.name}`);
    console.log(`   Old URL: ${oldUrl}`);
    console.log(`   New URL: ${newUrl}`);
    
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
  }
}

// Usage information
function showUsage() {
  console.log(`
Usage: node update-product-image.js <productId> <imageIndex> <newUrl>

Example:
  node update-product-image.js M9zIWUL0D8IZLwT0K7Lo 0 "https://storage.googleapis.com/..."

Arguments:
  productId   - The Firestore document ID of the product
  imageIndex  - Index of the image to update (0 for first image, 1 for second, etc.)
  newUrl      - The new Firebase Storage URL

To get the product IDs with Pinterest images, run:
  node migrate-images.js --list
  `);
}

// Parse command line arguments
const args = process.argv.slice(2);

if (args.length !== 3) {
  showUsage();
  process.exit(1);
}

const [productId, imageIndexStr, newUrl] = args;
const imageIndex = parseInt(imageIndexStr, 10);

if (isNaN(imageIndex)) {
  console.log('❌ Image index must be a number');
  showUsage();
  process.exit(1);
}

updateProductImage(productId, imageIndex, newUrl)
  .then(() => process.exit(0))
  .catch(error => {
    console.error('Error:', error);
    process.exit(1);
  });
