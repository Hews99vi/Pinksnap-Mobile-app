# Fix Existing Products in Firestore

## ⚠️ CRITICAL: Update All Products with Valid categoryKey

Your logs show many products have `categoryKey='null'` or invalid values. These products **won't work with ML image search**.

## How to Fix in Firebase Console

1. **Open Firebase Console**: https://console.firebase.google.com
2. **Navigate to**: Firestore Database → `products` collection
3. **For each product**, edit and set the correct `categoryKey`

## categoryKey Mapping Guide

Use this table to set the correct `categoryKey` for each product:

| Product Type | Set categoryKey to |
|--------------|-------------------|
| Hoodies, Sweatshirts, Pullovers | `HOODIE` |
| T-Shirts, Tees | `T_SHIRT` |
| Shirts, Blouses, Button-ups | `SHIRT` |
| Tank Tops, Crop Tops, Basic Tops | `TOP` |
| Pants, Jeans, Trousers | `PANTS` |
| Shorts | `SHORTS` |
| Shoes, Sneakers, Heels, Boots | `SHOES` |
| Hats, Caps | `HAT` |
| **Dresses** (choose specific type): | |
| - Dresses with straps, Sundresses | `STRAP_DRESS` |
| - Strapless Dresses, Evening Gowns | `STRAPLESS_FROCK` |
| - Long Sleeve Dresses | `LONG_SLEEVE_FROCK` |

## Valid Model Keys (11 total)

✅ These are the **ONLY** valid values:
```
HAT
HOODIE
PANTS
SHIRT
SHOES
SHORTS
TOP
T_SHIRT
LONG_SLEEVE_FROCK
STRAP_DRESS
STRAPLESS_FROCK
```

❌ Invalid examples (will NOT work):
- `TOPS` (should be `TOP`)
- `DRESSES` (should be `STRAP_DRESS`, `STRAPLESS_FROCK`, or `LONG_SLEEVE_FROCK`)
- `T-SHIRT` (should be `T_SHIRT` with underscore)
- `null` (must be a valid key)

## Examples from Your Logs

Based on your products, here are specific fixes:

```
Product: "Baggy t shirt"
Current: categoryKey='null'
Fix to: categoryKey='T_SHIRT'

Product: "Summer Floral Dress"
Current: categoryKey='null'
Fix to: categoryKey='STRAP_DRESS'

Product: "Hoodie"
Current: categoryKey='null'
Fix to: categoryKey='HOODIE'

Product: "Blue Jeans"
Current: categoryKey='null'
Fix to: categoryKey='PANTS'

Product: "Running Shoes"
Current: categoryKey='null'
Fix to: categoryKey='SHOES'
```

## Quick Fix Process

For each product in Firestore:

1. **Look at the product name/description**
2. **Determine what type of clothing it is**
3. **Find the matching model key from the table above**
4. **Edit the product document**
5. **Add/Update field**: `categoryKey` = `[MODEL_KEY]`
6. **Save**

## Bulk Update Option

If you have many products, you can use Firebase console's "Add field" feature:

1. Click on a product document
2. Add field: `categoryKey`
3. Type: `string`
4. Value: Choose from valid keys above
5. Click "Update"

## After Fixing

Once all products have valid `categoryKey` values:

✅ Image search will work correctly
✅ ML predictions will match products
✅ Users will see relevant results
✅ No more "Category Not Available" messages

## Verify in Logs

After fixing, when you run the app, you should see:

```
LOADED PRODUCT 'Baggy t shirt' categoryKey='T_SHIRT'  ✅
LOADED PRODUCT 'Summer Floral Dress' categoryKey='STRAP_DRESS'  ✅
LOADED PRODUCT 'Hoodie' categoryKey='HOODIE'  ✅
```

Instead of:

```
LOADED PRODUCT 'Baggy t shirt' categoryKey='null'  ❌
```

## Future Products

✅ The updated `add_product_screen.dart` now automatically:
- Maps UI categories to valid model keys
- Validates before saving
- Shows an error if category can't be mapped
- Displays the model key that will be used

So **new/edited products** will automatically get the correct `categoryKey`.

## Questions?

- Model key not sure? Use the table above
- Product doesn't fit any category? Use the closest match or leave blank
- Multiple types (e.g., "Dress Shirt")? Choose the primary type (`SHIRT`)
