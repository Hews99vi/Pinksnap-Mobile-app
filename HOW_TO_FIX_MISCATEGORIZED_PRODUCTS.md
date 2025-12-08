# How to Fix Miscategorized Products

## The Problem

Products in your Firebase database have wrong `categoryKey` values that don't match their names:
- "long sleeve dress" has `categoryKey: 'STRAPLESS_FROCK'` (should be `LONG_SLEEVE_FROCK`)
- Other similar mismatches

## Step 1: Run the App and Check Logs

The enhanced logging will now show:

```
🚨 MISMATCH FOUND!
   Product: "long sleeve dress"
   Price: $22.00
   Raw categoryKey from DB: "STRAPLESS_FROCK"
   Normalized to: "STRAPLESS_FROCK"
   Expected: "LONG_SLEEVE_FROCK"

🔍 ALL PRODUCTS IN STRAPLESS_FROCK CATEGORY:
   - Plain white dress ($15.00) | raw key: STRAPLESS_FROCK
   - long sleeve dress ($22.00) | raw key: STRAPLESS_FROCK  ← WRONG!
   - Elegant Evening Strapless Dress ($129.99) | raw key: STRAPLESS_FROCK

🔍 ALL PRODUCTS IN LONG_SLEEVE_FROCK CATEGORY:
   (none)  ← Should have products here!
```

## Step 2: Fix the Database

### Option A: Automatic Fix (Recommended)

Add this code to your app (e.g., in a debug button or main.dart for one-time run):

```dart
import 'package:get/get.dart';
import 'utils/database_fix_utility.dart';

// Add a debug button or call this once:
void fixDatabase() async {
  // STEP 1: DRY RUN (safe - just shows what will be fixed)
  await DatabaseFixUtility.fixMiscategorizedProducts(dryRun: true);
  
  // STEP 2: If dry run looks good, run actual fix
  // await DatabaseFixUtility.fixMiscategorizedProducts(dryRun: false);
}
```

Or use the quick fix for known issues:

```dart
// Quick fix for "long sleeve" and "strapless" products
await DatabaseFixUtility.quickFix(dryRun: true);  // dry run first
// await DatabaseFixUtility.quickFix(dryRun: false);  // then actual fix
```

### Option B: Manual Fix via Firebase Console

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Go to Firestore Database
4. Find the `products` collection
5. Search for products with mismatched names/categoryKeys
6. Edit each product's `categoryKey` field

For example:
- Product: "long sleeve dress" → Set `categoryKey` to `LONG_SLEEVE_FROCK`
- Product: "strapless evening dress" → Set `categoryKey` to `STRAPLESS_FROCK`

### Option C: Fix Specific Products by Name

```dart
// Fix all products with "long sleeve" in name
await DatabaseFixUtility.fixProductsByNamePattern(
  namePattern: 'long sleeve',
  correctCategoryKey: 'LONG_SLEEVE_FROCK',
  dryRun: true,  // set to false to actually fix
);
```

## Step 3: Verify the Fix

After fixing, restart the app and check the logs:

```
🔍 ALL PRODUCTS IN STRAPLESS_FROCK CATEGORY:
   - Plain white dress ($15.00) | raw key: STRAPLESS_FROCK
   - Elegant Evening Strapless Dress ($129.99) | raw key: STRAPLESS_FROCK
   ✅ No more "long sleeve dress" here!

🔍 ALL PRODUCTS IN LONG_SLEEVE_FROCK CATEGORY:
   - long sleeve dress ($22.00) | raw key: LONG_SLEEVE_FROCK
   ✅ Now correctly categorized!
```

## Step 4: Test Image Search

1. Take/upload a photo of a long sleeve dress
2. Check the logs to see predicted category
3. Verify search results now show correct products

## Validation Tools Available

### 1. Product Validation (Automatic)
- Runs automatically when products load
- Shows validation summary in console
- Located in: `lib/utils/product_validation_helper.dart`

### 2. Debug Tools (Manual)
- `ProductDebugTools.validateAllProducts()` - Check all products
- `ProductDebugTools.showCategoryDistribution()` - Show products by category
- Located in: `lib/utils/product_debug_tools.dart`

### 3. Database Fix Utility (One-time Fix)
- `DatabaseFixUtility.fixMiscategorizedProducts()` - Auto-fix all mismatches
- `DatabaseFixUtility.quickFix()` - Quick fix for known issues
- `DatabaseFixUtility.fixProductsByNamePattern()` - Fix specific patterns
- Located in: `lib/utils/database_fix_utility.dart`

## Prevention: How to Avoid This in the Future

### When Adding Products via Admin Panel

Make sure the admin panel uses the correct categoryKey mapping:

```dart
// In your add/edit product screen
import '../utils/product_validation_helper.dart';

// Before saving:
final suggestedKey = ProductValidationHelper.suggestCategoryKey(productName);
debugPrint('Suggested categoryKey for "$productName": $suggestedKey');

// Show suggestion to admin or auto-populate
```

### When Seeding Database

Check `lib/services/firebase_data_seeder.dart` and ensure all products have correct keys:

```dart
Product(
  name: 'Long Sleeve Party Dress',  // ← Name mentions "long sleeve"
  categoryKey: _key('LONG_SLEEVE_FROCK'),  // ← Must match!
  // ...
),
```

## Model Keys Reference

Valid model keys from `assets/models/labels.txt`:

- `HAT`
- `HOODIE`
- `PANTS` (plural)
- `SHIRT`
- `SHOES` (plural)
- `SHORTS` (plural)
- `TOP`
- `T_SHIRT`
- `LONG_SLEEVE_FROCK`
- `STRAP_DRESS`
- `STRAPLESS_FROCK`

## Summary

1. ✅ **Enhanced logging added** - Shows detailed mismatch info
2. ✅ **Automatic validation** - Runs on every product load
3. ✅ **Database fix utility** - Can auto-correct all mismatches
4. ✅ **Prevention tools** - Validate before saving new products

Run `flutter run` to see the enhanced logs, then use the fix utility to correct the database!
