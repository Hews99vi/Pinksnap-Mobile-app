/**
 * Check Admin Custom Claims - Verification Script
 * 
 * This script checks if the admin custom claim is actually set in Firebase.
 * Run this FIRST to verify the claim status before trying to set it.
 */

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const uid = "F8WAmOj9trhqw0atmaYVk58n8d03";

(async () => {
  try {
    console.log("\n🔍 CHECKING ADMIN CLAIM STATUS...\n");
    
    const user = await admin.auth().getUser(uid);
    
    console.log("Project ID:", serviceAccount.project_id);
    console.log("User Email:", user.email);
    console.log("User UID:", user.uid);
    console.log("Custom Claims:", user.customClaims || "undefined (no claims set)");
    
    console.log("\n" + "=".repeat(70));
    
    if (user.customClaims && user.customClaims.admin === true) {
      console.log("✅ ADMIN CLAIM IS SET!");
      console.log("\nNext steps:");
      console.log("1. Sign OUT of the Flutter app");
      console.log("2. Sign IN again");
      console.log("3. Check Flutter logs for: admin claim: true");
    } else {
      console.log("❌ ADMIN CLAIM IS NOT SET");
      console.log("\nTo fix this, run:");
      console.log("  node set-admin-claim.js " + uid);
      console.log("\nOR run the combined script:");
      console.log("  node set-and-verify-admin.js");
    }
    
    console.log("=".repeat(70) + "\n");
    
    process.exit(0);
  } catch (error) {
    console.error("\n❌ ERROR:", error.message);
    
    if (error.code === 'auth/user-not-found') {
      console.error("\nUser not found in this Firebase project!");
      console.error("Check that project_id in serviceAccountKey.json = pinksnap-mobile-app");
    }
    
    process.exit(1);
  }
})();
