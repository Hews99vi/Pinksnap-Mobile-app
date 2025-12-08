/**
 * Set Admin Claim and Verify Immediately
 * 
 * This script:
 * 1. Sets the admin custom claim
 * 2. Immediately reads it back to verify it worked
 */

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const uid = "F8WAmOj9trhqw0atmaYVk58n8d03";

(async () => {
  try {
    console.log("\n🔧 SETTING ADMIN CLAIM...\n");
    console.log("Project ID:", serviceAccount.project_id);
    console.log("Target UID:", uid);
    
    // Set the claim
    await admin.auth().setCustomUserClaims(uid, { admin: true });
    console.log("\n✅ setCustomUserClaims() completed");
    
    // Immediately verify
    console.log("\n🔎 VERIFYING...\n");
    const user = await admin.auth().getUser(uid);
    
    console.log("User Email:", user.email);
    console.log("Custom Claims:", user.customClaims);
    
    console.log("\n" + "=".repeat(70));
    
    if (user.customClaims && user.customClaims.admin === true) {
      console.log("✅ SUCCESS! Admin claim verified immediately!");
      console.log("\nCRITICAL NEXT STEPS:");
      console.log("1. In Flutter app: SIGN OUT completely");
      console.log("2. SIGN IN again (forces token refresh)");
      console.log("3. Check Flutter logs - should show:");
      console.log("   🔐 Token Claims for admin@pinksnap1.com:");
      console.log("      - admin claim: true    ← Should be TRUE now!");
      console.log("\n4. If still shows null:");
      console.log("   • Check project_id above = pinksnap-mobile-app");
      console.log("   • Make sure you signed OUT then IN (not just restart)");
    } else {
      console.log("❌ WARNING: Claim not visible immediately after setting");
      console.log("\nPossible causes:");
      console.log("1. Wrong Firebase project");
      console.log("   → Check project_id above should be: pinksnap-mobile-app");
      console.log("2. Wrong UID");
      console.log("   → Should be: F8WAmOj9trhqw0atmaYVk58n8d03");
      console.log("\nTry running check-admin-claim.js to verify");
    }
    
    console.log("=".repeat(70) + "\n");
    
    process.exit(0);
  } catch (error) {
    console.error("\n❌ ERROR:", error.message);
    
    if (error.code === 'auth/user-not-found') {
      console.error("\n⚠️  User not found in this Firebase project!");
      console.error("This means:");
      console.error("• serviceAccountKey.json is from a DIFFERENT project");
      console.error("• Your app uses: pinksnap-mobile-app");
      console.error("• This key is from: " + serviceAccount.project_id);
      console.error("\nDownload the key from the CORRECT project!");
    }
    
    process.exit(1);
  }
})();
