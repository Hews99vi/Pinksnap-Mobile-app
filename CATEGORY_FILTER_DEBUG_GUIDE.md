# 🔍 Category Filter Debug Guide - Complete Code Flow

## Problem: Category filtering shows no products

---

## 📊 Data Flow Overview

```
Firestore products/           Firestore categories/
  └─ categoryKey field          └─ key field
          ↓                           ↓
  Product.fromJson()          Category.fromDoc()
  (normalizes key)            (fallback chain)
          ↓                           ↓
  ProductController           CategoryController
  _products (Rx)              _categories (Rx)
          ↓                           ↓
  SearchController            SearchController
  _allProducts                availableCategories
          ↓                           ↓
  _applyFilters()             (category chips)
  (compares keys)                     ↓
          ↓                    updateCategory(key)
  _filteredProducts                   ↓
          ↓                    _selectedCategory
  SearchScreen                        ↓
  (product grid)              _applyFilters()
```

---

## 🔑 Key Data Sources

### **Category Keys Come From TWO Sources:**

1. **PRIMARY: Firestore `categories/` collection**
   - Field: `key` (e.g., "HOODIE", "T_SHIRT")
   - Retrieved by: `CategoryController.loadCategories()`
   - Used in: `SearchController.availableCategories`

2. **FALLBACK: Product `categoryKey` fields**
   - If Firestore categories have empty `key` fields
   - Extracted from: `_allProducts.map((p) => p.categoryKey)`
   - Only used when: `visibleCats.isEmpty`

### **Critical Issue:**
If Firestore category docs have `key: ""` (empty), the filter chips won't show and filtering fails!

---

## 📄 Complete Code Files

### 1️⃣ **Product Model** (`lib/models/product.dart`)

**Normalization Logic:**
- Reads `categoryKey` OR `category` from Firestore
- Applies `_normalizeCategoryKey()` to convert to UPPER_SNAKE_CASE
- Handles plurals: `HOODIES` → `HOODIE`, `TOPS` → `TOP`

**Key Methods:**
```dart
static String _normalizeCategoryKey(String raw)
  → Returns: "HOODIE", "T_SHIRT", etc.
  → Aliases: HOODIES→HOODIE, T__SHIRT→T_SHIRT, etc.

factory Product.fromJson(Map<String, dynamic> json)
  → Reads: json['categoryKey'] ?? json['category']
  → Normalizes: _normalizeCategoryKey(rawCategoryKey)
  → Stores: categoryKey field (normalized)
```

**Data Fields:**
- `category` - Human-readable (e.g., "Hoodies")
- `categoryKey` - ML-compatible key (e.g., "HOODIE")

---

### 2️⃣ **Product Controller** (`lib/controllers/product_controller.dart`)

**Purpose:** Fetches products from Firestore, stores in reactive list

**Key Methods:**
```dart
Future<void> loadProducts()
  → Calls: FirebaseDbService.getAllProducts()
  → Returns: List<Product> with normalized categoryKey
  → Stores in: _products.assignAll(loadedProducts)
  → Triggers: ImageSearchService.rebuildIndex()

List<Product> getProductsByCategory(String categoryKey)
  → Compares: product.categoryKey == categoryKey (strict match)
  → Returns: Filtered list
```

**Debug Output:**
```dart
🔥 ProductController instance = 123456789
🔥 Products loaded = 50
=== CATEGORYKEY COUNTS ===
  HOODIE: 5
  T_SHIRT: 8
  STRAP_DRESS: 3
==========================
```

---

### 3️⃣ **Category Controller** (`lib/controllers/category_controller.dart`)

**Purpose:** Fetches categories from Firestore, manages visibility

**Key Methods:**
```dart
Future<void> loadCategories()
  → Calls: FirebaseDbService.getCategories()
  → Returns: List<Category> with key, name, isVisible, sortOrder
  → Stores in: _categories.assignAll(loadedCategories)

List<Category> get visibleShopCategories
  → Filters: c.isVisible == true
  → Sorts: by sortOrder
```

**Debug Output:**
```dart
🔥 RAW categories count = 11
🔥 cat name="Hoodies" key="HOODIE" visible=true sortOrder=1 id="HOODIE"
🔥 cat name="T-Shirts" key="T_SHIRT" visible=true sortOrder=7 id="T_SHIRT"
✅ Loaded 11 categories (11 visible)
```

**⚠️ If keys are empty:**
```dart
🔥 cat name="Hoodies" key="" visible=true sortOrder=0 id="0Iix1mAGsE5ztNqqUU5s"
                        ↑↑↑ PROBLEM!
```

---

### 4️⃣ **Search Controller** (`lib/controllers/search_controller.dart`)

**Purpose:** Manages filter state, applies category/price/size/color filters

**Critical Methods:**

#### A) `availableCategories` Getter
```dart
List<Map<String, String>> get availableCategories {
  // 1. Get categories from CategoryController
  final allCats = _categoryController.categories;
  
  // 2. Filter visible + non-empty keys
  final visibleCats = allCats
      .where((c) => c.isVisible && c.key.trim().isNotEmpty)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  
  // 3. FALLBACK: If no valid categories, use product keys
  if (visibleCats.isEmpty && _allProducts.isNotEmpty) {
    final productKeys = _allProducts
        .map((p) => p.categoryKey)
        .where((k) => k.isNotEmpty)
        .toSet()
        .toList();
    
    return [
      {'key': 'All', 'name': 'All'},
      ...productKeys.map((k) => {'key': k, 'name': k})
    ];
  }
  
  // 4. Return Firestore categories
  return [
    {'key': 'All', 'name': 'All'},
    ...visibleCats.map((c) => {'key': c.key, 'name': c.name})
  ];
}
```

**Debug Output:**
```dart
🔍 Building availableCategories from 11 Firestore categories
✅ Found 11 visible categories with keys
```

**⚠️ If Firestore keys empty:**
```dart
🔍 Building availableCategories from 11 Firestore categories
✅ Found 0 visible categories with keys
⚠️ No valid Firestore categories, falling back to product keys
```

#### B) `updateCategory()` Method
```dart
void updateCategory(String categoryKey) {
  // Prevent empty keys
  final safeKey = (categoryKey.isEmpty || categoryKey.trim().isEmpty) 
      ? 'All' 
      : categoryKey;
  
  _selectedCategory.value = safeKey;
  // Triggers everAll → _scheduleFilter() → _applyFilters()
}
```

#### C) `_applyFilters()` Method
```dart
void _applyFilters() {
  final cat = _selectedCategory.value;
  
  final filtered = _allProducts.where((product) {
    // Category filter - EXACT KEY MATCH
    final matchesCategory = (cat == 'All') || (product.categoryKey == cat);
    
    // ... other filters (search, size, color, price)
    
    return matchesSearch && matchesCategory && matchesSize && matchesColor && matchesPrice;
  }).toList();
  
  _filteredProducts.assignAll(filtered);
  
  // Debug if no results
  if (cat != 'All' && filtered.isEmpty) {
    debugPrint('⚠️ No products for category "$cat"');
    final uniqueKeys = _allProducts.map((p) => p.categoryKey).toSet().toList();
    debugPrint('📋 Available keys: $uniqueKeys');
  }
}
```

**Filter Comparison Logic:**
```dart
product.categoryKey == cat
    ↓
"HOODIE" == "HOODIE"  ✅ Match
"HOODIE" == "HOODIES" ❌ No match (must be normalized)
"HOODIE" == ""        ❌ No match
```

---

### 5️⃣ **Search Screen UI** (`lib/screens/search_screen.dart`)

**Purpose:** Renders category chips and product grid

**Category Chips Rendering:**
```dart
Obx(() {
  final categories = searchController.availableCategories;
  
  // Debug
  debugPrint('🎨 Rendering ${categories.length} category chips');
  
  return Wrap(
    children: categories.map((category) {
      final key = category['key']!;    // "HOODIE"
      final name = category['name']!;  // "Hoodies"
      
      return InkWell(
        onTap: () {
          searchController.updateCategory(key);  // Pass key only
        },
        child: Chip(
          label: Text(name),  // Display name
          backgroundColor: searchController.selectedCategory == key
              ? Colors.pink[400]
              : Colors.grey[200],
        ),
      );
    }).toList(),
  );
})
```

**Product Grid Rendering:**
```dart
Obx(() {
  if (searchController.filteredProducts.isEmpty) {
    return Center(child: Text('No Products Found'));
  }
  
  return GridView.builder(
    itemCount: searchController.filteredProducts.length,
    itemBuilder: (context, index) {
      final product = searchController.filteredProducts[index];
      return ProductCard(product: product);
    },
  );
})
```

---

### 6️⃣ **Firebase DB Service** (`lib/services/firebase_db_service.dart`)

**Product Fetching:**
```dart
static Future<List<Product>> getAllProducts() async {
  QuerySnapshot snapshot = await _firestore
      .collection('products')
      .get();

  return snapshot.docs
      .map((doc) => Product.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }))
      .toList();
}
```

**Category Fetching:**
```dart
static Future<List<Category>> getCategories() async {
  QuerySnapshot snapshot = await _firestore
      .collection('categories')
      .get();

  return snapshot.docs
      .map((doc) => Category.fromDoc(doc.id, doc.data()))
      .toList();
}
```

---

## 🐛 Common Issues & Debugging

### Issue 1: "Only 'All' chip shows, no other categories"

**Root Cause:** Firestore category docs have `key: ""`

**Debug Logs:**
```
🔥 cat name="Hoodies" key="" visible=true
🔥 cat name="Pants" key="" visible=true
🔍 Building availableCategories from 11 Firestore categories
✅ Found 0 visible categories with keys
⚠️ No valid Firestore categories, falling back to product keys
🎨 Rendering 1 category chips  ← Only "All"
```

**Fix:** Run category seeder
```dart
await CategorySeeder.seedDefaultCategories();
```

**Expected After Fix:**
```
🔥 cat name="Hoodies" key="HOODIE" visible=true
✅ Found 11 visible categories with keys
🎨 Rendering 12 category chips  ← All + 11 categories
```

---

### Issue 2: "Category chip shows, but selecting it returns 0 products"

**Root Cause:** Key mismatch between category key and product categoryKey

**Debug Logs:**
```
🔍 Selected category key: "HOODIES"
⚠️ No products for category "HOODIES"
📋 Available keys: [HOODIE, PANTS, SHIRT, T_SHIRT]
                     ↑↑↑ Products use "HOODIE" (singular)
```

**Verification:**
```dart
// Check product keys
=== CATEGORYKEY COUNTS ===
  HOODIE: 5
  PANTS: 8
  T_SHIRT: 3
==========================

// Check category keys
🔥 cat key="HOODIES"  ← Mismatch! Should be "HOODIE"
```

**Fix:** Ensure Firestore category keys match normalized product keys
```dart
// Firestore: categories/HOODIE
{
  "name": "Hoodies",
  "key": "HOODIE",      // Must match product keys
  "isVisible": true
}
```

---

### Issue 3: "Products exist but filter shows 0 results"

**Root Cause:** Price range or other filter too restrictive

**Debug:**
```dart
// Check price bounds
💰 Stable price bounds: $0 - $1000

// Check selected filters
🔍 Selected category key: "HOODIE"
Selected size: "XL"
Selected price: $500-$600

// Check product data
Product "Blue Hoodie":
  categoryKey: "HOODIE" ✅
  sizes: ["S", "M", "L"]  ❌ No XL!
  price: $45  ✅
```

**Fix:** Clear filters or adjust
```dart
searchController.clearAllFilters();
```

---

### Issue 4: "Filter going crazy / spam"

**Root Cause:** Multiple filter triggers

**Debug Logs:**
```
_applyFilters called  // User taps chip
_applyFilters called  // everAll triggers
_applyFilters called  // Manual call
_applyFilters called  // Another trigger
```

**Fix:** Already implemented with debouncing
```dart
void _scheduleFilter() {
  _filterTimer?.cancel();
  _filterTimer = Timer(const Duration(milliseconds: 80), _applyFilters);
}
```

---

## ✅ Debugging Checklist

### 1. Check Firestore Category Data
```
Open Firebase Console → Firestore → categories/

Expected:
  HOODIE/
    name: "Hoodies"
    key: "HOODIE"       ← Must exist!
    isVisible: true
    sortOrder: 1
```

### 2. Check Product Data
```
Open Firebase Console → Firestore → products/

Expected:
  {productId}/
    name: "Blue Hoodie"
    categoryKey: "HOODIE"  ← Must match category key
    category: "Hoodies"    ← Optional, for display
    price: 45
```

### 3. Run App with Logs
```dart
// Look for these in console:

// Products loaded?
🔥 Products loaded = 50

// Category keys distribution?
=== CATEGORYKEY COUNTS ===
  HOODIE: 5
  T_SHIRT: 8
==========================

// Categories loaded?
🔥 RAW categories count = 11
🔥 cat name="Hoodies" key="HOODIE" visible=true

// Filter chips rendered?
🎨 Rendering 12 category chips

// Category selected?
🔍 Selected category key: "HOODIE"

// Results found?
⚠️ No products for category "HOODIE"  ← Problem!
📋 Available keys: [HOODIE, PANTS, ...]
```

### 4. Verify Normalization
```dart
// In ProductController._debugCategoryDistribution():
=== CATEGORYKEY COUNTS ===
  HOODIE: 5        ← Singular (correct)
  T_SHIRT: 8       ← Underscore (correct)
  STRAP_DRESS: 3   ← Singular (correct)
==========================

// If you see:
  HOODIES: 5       ← Plural (wrong - normalization failed)
  T-SHIRT: 8       ← Hyphen (wrong - should be underscore)
```

### 5. Test Filter Flow
```
1. Open search screen
2. Tap filter icon → Filter panel opens
3. Check category chips:
   - Should see: All, Hat, Hoodie, Pants, etc.
   - Should NOT see: Only "All"

4. Tap "Hoodie" chip:
   - Chip turns pink (selected)
   - Product grid updates
   - Should show hoodie products

5. Check console:
   🔍 Selected category key: "HOODIE"
   💰 Stable price bounds: $0 - $1000
   (No spam filter calls)

6. If 0 products:
   ⚠️ No products for category "HOODIE"
   📋 Available keys: [HOODIE, PANTS, SHIRT, ...]
   → Compare "HOODIE" in both lists (must match exactly)
```

---

## 🎯 Key Takeaways

1. **Category keys MUST exist in Firestore** (not empty)
2. **Product categoryKey MUST match category key** (exact, case-sensitive)
3. **Normalization happens on Product.fromJson()** (automatic)
4. **SearchController compares exact keys** (product.categoryKey == selectedCategory)
5. **Fallback uses product keys** (if Firestore empty)

---

## 🚀 Quick Fix Steps

1. **Run seeder to populate keys:**
   ```dart
   await CategorySeeder.seedDefaultCategories();
   ```

2. **Restart app** (hot restart, not hot reload)

3. **Check logs:**
   ```
   ✅ Found 11 visible categories with keys
   🎨 Rendering 12 category chips
   ```

4. **Test filter:**
   - Tap category chip
   - Should see products

5. **If still 0 products:**
   - Check console for key mismatch
   - Compare category key vs product keys
   - Fix Firestore data if needed

---

**Status:** All code reviewed and documented  
**Next:** Run seeder + test filter flow
