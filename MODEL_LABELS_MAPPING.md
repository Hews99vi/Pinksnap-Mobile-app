# Model Labels and Category Mapping

## Updated Model Information
- **Model File**: `assets/models/model_unquant.tflite`
- **Labels File**: `assets/models/labels.txt`
- **Model Type**: TFLite Floating Point (Unquantized)
- **Last Updated**: December 6, 2025

## Model Labels (11 Categories)

The updated model can detect the following clothing items:

1. **Hat** - Headwear, caps, hats
2. **Hoodie** - Hoodies, sweatshirts
3. **Pants** - Trousers, jeans, bottoms
4. **Shirt** - Shirts, blouses
5. **Shoes** - Footwear, sneakers, heels, sandals, boots
6. **Shorts** - Short pants
7. **Top** - Tops, crop tops, tank tops
8. **T-Shirt** - T-shirts, tees
9. **Long sleeve frock** - Long sleeve dresses, gowns
10. **Strap Dresses** - Sundresses, summer dresses with straps
11. **Strapless Frocks** - Evening dresses, formal dresses without straps

## Category Mapping to Shop Products

The image search system maps model predictions to your shop's product categories using the following logic:

### Label → Category Mapping

```dart
{
  'hat': ['hat', 'hats', 'cap', 'caps', 'headwear'],
  'hoodie': ['hoodie', 'hoodies', 'sweatshirt', 'sweatshirts'],
  'pants': ['pants', 'trousers', 'jeans', 'bottoms'],
  'shirt': ['shirt', 'shirts', 'blouse', 'blouses'],
  'shoes': ['shoes', 'footwear', 'sneakers', 'heels', 'sandals', 'boots'],
  'shorts': ['shorts', 'short pants'],
  'top': ['top', 'tops', 'crop top', 'tank top', 'camisole'],
  't-shirt': ['t-shirt', 't shirts', 't-shirts', 'tee', 'tees', 'tshirt'],
  'long sleeve frock': ['long sleeve frock', 'long sleeve frocks', 'long dress'],
  'strap dresses': ['strap dresses', 'strap dress', 'sundress'],
  'strapless frocks': ['strapless frocks', 'strapless frock', 'strapless dress'],
}
```

## How Product Matching Works

1. **Image Upload**: User uploads an image through gallery or camera
2. **Model Prediction**: TFLite model analyzes the image and returns predictions with confidence scores
3. **Category Mapping**: The predicted label is mapped to potential product categories using the mapping above
4. **Product Search**: The system searches for products in your shop that match the mapped categories
5. **Results Display**: Matching products are shuffled and displayed (up to 10 products)

### Example Flow:

**User uploads image of a dress with straps**
```
1. Model predicts: "Strap Dresses" (85% confidence)
2. Maps to categories: ['dress', 'dresses', 'strap dress', 'sundress', 'summer dress']
3. Searches products where:
   - product.name contains 'dress', 'sundress', etc. OR
   - product.category contains 'dress', 'sundress', etc.
4. Returns up to 10 matching products
```

## Missing Categories

If the model detects a category but no products are found, the user will see a message:

> "Category Not Available - Detected: [Label] ([X]% confidence)
> No products found in this category yet. This category will be added soon!"

This allows you to:
- See which categories are being detected
- Add products to those categories in the future
- Expand your product catalog based on search demand

## Adding Products for New Categories

To add products for detected categories:

1. Go to your Firebase Console → Firestore
2. Add products with categories that match the label mappings above
3. Example: For "Hoodie" detection, add products with:
   - `category: "Hoodie"` or
   - `category: "Hoodies"` or
   - `name: "Cozy Hoodie"` (contains "hoodie" in name)

## Current Shop Categories

Based on the codebase, your shop currently has products in these categories:
- Tops
- Jackets
- Blouses
- (Add more as you expand your catalog)

## Recommendations

### Categories to Add:
1. **Dresses** - Highly needed since model detects 3 dress types
2. **Shoes** - Common search category
3. **Pants** - Basic clothing category
4. **T-Shirts** - Popular casual wear

### Product Naming Tips:
- Include the category name in product titles for better matching
- Example: "Floral Summer Dress" will match "strap dresses" detection
- Example: "Classic White T-Shirt" will match "t-shirt" detection

## Testing the Model

To test the model with different images:

1. Run the app: `flutter run`
2. Navigate to "Search by Image"
3. Upload test images of different clothing items
4. Check the prediction results and matched products
5. Monitor the console logs for matching details

## Model Performance

- **Confidence Threshold**: No minimum threshold currently applied
- **Top Prediction**: System uses the highest confidence prediction first
- **Fallback**: If no match found, tries top 3 predictions
- **Empty Results**: Returns empty list if no categories match (instead of random products)

## Future Enhancements

1. Add minimum confidence threshold (e.g., 50%)
2. Implement color and pattern matching
3. Add price range filtering based on detected item type
4. Track search analytics to identify popular categories
5. Implement multi-item detection for outfit recommendations
