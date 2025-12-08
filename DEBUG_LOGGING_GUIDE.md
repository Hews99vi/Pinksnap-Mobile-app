# Debug Logging Reference Guide

## Category Toggle Logs

### ✅ Success Case
```
🔄 Toggling visibility for Strap Dress (id: STRAP_DRESS, key: STRAP_DRESS) to false
✅ Updated visibility for Strap Dress (id: STRAP_DRESS): false
✅ Updated local category list at index 9
✅ Toggled visibility for Strap Dress: false
```

### ❌ Error Case (if it occurs)
```
🔄 Toggling visibility for Strap Dress (id: STRAP_DRESS, key: STRAP_DRESS) to false
❌ Error updating category visibility for Strap Dress (id: STRAP_DRESS): [FIRESTORE_ERROR]
⚠️ Category not found in local list: STRAP_DRESS
```

**What to check:**
- Verify the doc ID exists in Firestore
- Check if category was deleted
- Verify Firestore rules allow updates

---

## Category Filter Logs

### ✅ Success Case
```
🔍 Selected category key: STRAP_DRESS
🔍 Filter results: 5 products found
🔍 Category filter: STRAP_DRESS
```

### ⚠️ No Products Found
```
🔍 Selected category key: STRAPLESS_FROCK
🔍 Filter results: 0 products found
🔍 Category filter: STRAPLESS_FROCK
⚠️ No products found for category STRAPLESS_FROCK
Available product keys: [STRAP_DRESS, HAT, HOODIE, SHIRT, T_SHIRT, ...]
```

**What to check:**
- Compare selected key with available keys list
- Check if products actually have this categoryKey
- Run data migration if keys are inconsistent

---

## Price Range Logs

### Normal Operation
```
🔍 Filter results: 28 products found
Price range clamped: 10.0 - 150.0
```

### Empty Results
```
🔍 Filter results: 0 products found
Price range reset: 0.0 - 0.0
```

### After Category Change
```
🔍 Selected category key: HAT
🔍 Filter results: 3 products found
Price range clamped: 15.0 - 45.0
```

---

## Common Issues & Solutions

### Issue: "No products found" but should show products

**Check:**
1. Product's categoryKey value in Firestore
   ```dart
   debugPrint('Product: ${product.name}');
   debugPrint('  categoryKey: "${product.categoryKey}"');
   ```

2. Selected category key
   ```dart
   debugPrint('Selected: "${selectedCategory}"');
   ```

3. Compare normalized versions
   ```dart
   debugPrint('Normalized product: ${CategoryHelper.normalizeToKey(product.categoryKey)}');
   debugPrint('Normalized selected: ${CategoryHelper.normalizeToKey(selectedCategory)}');
   ```

**Common mismatches:**
- `"STRAP_DRESSES"` vs `"STRAP_DRESS"` (plural)
- `"Strap Dress"` vs `"STRAP_DRESS"` (case/spaces)
- `"strap_dress"` vs `"STRAP_DRESS"` (case)

**Fix:**
Use CategoryHelper to normalize both sides, or update product data to use consistent keys.

---

### Issue: RangeSlider crash

**Error message:**
```
RangeSlider's values must be between min and max
min <= values.start <= values.end <= max
```

**Check logs:**
```
Min price: 50.0
Max price: 30.0  ← ERROR: max < min!
Current range: 10.0 - 100.0
Filtered products: 0
```

**This should not happen anymore** after the fix, but if it does:
1. Check `_clampPriceRange()` is being called
2. Verify filtered products list is updated before clamping
3. Check for race conditions in filter updates

---

## Firestore Query Debugging

### Check Document ID
```dart
final doc = await FirebaseFirestore.instance
    .collection('categories')
    .doc('STRAP_DRESS')
    .get();
    
debugPrint('Doc exists: ${doc.exists}');
debugPrint('Doc ID: ${doc.id}');
debugPrint('Doc data: ${doc.data()}');
```

### List All Category IDs
```dart
final snapshot = await FirebaseFirestore.instance
    .collection('categories')
    .get();
    
for (var doc in snapshot.docs) {
  debugPrint('ID: ${doc.id}, Key: ${doc.data()['key']}, Name: ${doc.data()['name']}');
}
```

### Find Products by Category
```dart
final products = await FirebaseFirestore.instance
    .collection('products')
    .where('categoryKey', isEqualTo: 'STRAP_DRESS')
    .get();
    
debugPrint('Found ${products.docs.length} products');
```

---

## VS Code Debug Tips

### Enable All Logs
In `main.dart`:
```dart
void main() {
  debugPrint('🚀 App starting...');
  debugPrintEnabled = true;  // Enable all debug prints
  runApp(MyApp());
}
```

### Filter Logs in Debug Console
- Search for `🔍` to see filter operations
- Search for `🔄` to see category toggles
- Search for `❌` to see errors
- Search for `⚠️` to see warnings

### Add Custom Breakpoints
In `search_controller.dart`:
```dart
void _applyFilters() {
  debugger();  // ← Execution will pause here
  // ... rest of method
}
```

---

## Data Verification Checklist

Before reporting an issue, verify:

1. **Categories loaded correctly**
   ```
   ✓ Categories have id, key, name
   ✓ Visible categories shown in filter chips
   ✓ Category keys match labels.txt format
   ```

2. **Products loaded correctly**
   ```
   ✓ Products have categoryKey field
   ✓ categoryKey values are UPPER_SNAKE_CASE
   ✓ categoryKey values exist in categories
   ```

3. **Filter state correct**
   ```
   ✓ selectedCategory shows key, not name
   ✓ Price range within min/max
   ✓ Filtered products list updates
   ```

4. **UI state correct**
   ```
   ✓ Selected chip highlighted
   ✓ Product count matches filtered list
   ✓ Price slider shows correct range
   ✓ Empty state shows when appropriate
   ```
