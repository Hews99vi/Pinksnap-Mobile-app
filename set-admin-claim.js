/**
 * Set Admin Custom Claim for Firebase User
 * 
 * This script sets the 'admin' custom claim for a user in Firebase Authentication.
 * 
 * Prerequisites:
 * 1. Install Firebase Admin SDK: npm install firebase-admin
 * 2. Download service account key from Firebase Console:
 *    - Go to Project Settings > Service Accounts
 *    - Click "Generate New Private Key"
 *    - Save as 'serviceAccountKey.json' in this directory
 * 
 * Usage by UID (recommended):
 *   node set-admin-claim.js F8WAmOj9trhqw0atmaYVk58n8d03
 * 
 * Usage by email:
 *   node set-admin-claim.js admin@pinksnap1.com
 * 
 * Or modify the default values below and run:
 *   node set-admin-claim.js
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
try {
  const serviceAccount = require('./serviceAccountKey.json');
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  
  console.log('✅ Firebase Admin SDK initialized');
  console.log(`   Project ID: ${serviceAccount.project_id}`);
  console.log('\n⚠️  CRITICAL: Verify this matches your app\'s Firebase project!');
  console.log('   Your app uses: pinksnap-mobile-app (from token logs)');
  console.log('   If project_id above is different, you have the WRONG service account key!\n');
} catch (error) {
  console.error('❌ Error: Could not find serviceAccountKey.json');
  console.error('   Please download it from Firebase Console > Project Settings > Service Accounts');
  console.error('   Save it as "serviceAccountKey.json" in this directory');
  process.exit(1);
}

// Get identifier from command line or use default
// From your logs: UID is F8WAmOj9trhqw0atmaYVk58n8d03
const identifier = process.argv[2] || 'F8WAmOj9trhqw0atmaYVk58n8d03';

// Detect if it's a UID (no @ sign) or email
const isUID = !identifier.includes('@');

console.log(`\n🔄 Setting admin claim for: ${identifier} ${isUID ? '(UID)' : '(Email)'}\n`);

async function setAdminClaim() {
  try {
    let user;
    
    if (isUID) {
      // Look up by UID directly
      user = await admin.auth().getUser(identifier);
      console.log(`✅ Found user: ${user.email} (UID: ${user.uid})`);
    } else {
      // Look up by email
      user = await admin.auth().getUserByEmail(identifier);
      console.log(`✅ Found user: ${user.email} (UID: ${user.uid})`);
    }
    
    // Set custom claim
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });
    
    console.log(`\n✅ SUCCESS! Admin claim set for UID: ${user.uid}`);
    console.log(`   Email: ${user.email}`);
    console.log('\n⚠️  CRITICAL NEXT STEPS:');
    console.log('   1. SIGN OUT of the app completely');
    console.log('   2. SIGN IN again');
    console.log('   3. Check Flutter logs - MUST see:');
    console.log('      🔐 Token Claims for admin@pinksnap1.com:');
    console.log('         - admin claim: true    ← MUST BE TRUE, NOT NULL!');
    console.log('   4. If still null:');
    console.log('      • Wrong project! Check project_id above = pinksnap-mobile-app');
    console.log('      • Force refresh in Flutter:');
    console.log('        final token = await FirebaseAuth.instance.currentUser?.getIdTokenResult(true);');
    console.log('        debugPrint("admin: ${token?.claims?[\'admin\']}");');
    console.log('   5. Once claim = true, test order status update');
    console.log('   6. Should see: "Status update notification sent" (no PERMISSION_DENIED)\n');
    
    process.exit(0);
  } catch (error) {
    console.error('\n❌ ERROR:', error.message);
    
    if (error.code === 'auth/user-not-found') {
      console.error(`   User ${identifier} does not exist in Firebase Auth`);
      console.error('   Please create the user first or check the identifier');
    } else if (error.code === 'auth/invalid-uid') {
      console.error('   Invalid UID format. UIDs should be alphanumeric strings.');
    }
    
    process.exit(1);
  }
}

setAdminClaim();
