# Image Search with TensorFlow Lite - Setup Guide

## Overview
This document explains how the image search feature has been integrated with your trained TensorFlow Lite model for fashion item classification.

## What Has Been Implemented

### 1. **TFLite Model Service** (`lib/services/tflite_model_service.dart`)
A dedicated service to handle all TensorFlow Lite operations:
- **Model Loading**: Automatically loads your `model_unquant.tflite` and `labels.txt` from assets
- **Image Classification**: Classifies images and returns top predictions with confidence scores
- **Label Management**: Handles the fashion categories (Dress, Hat, Hoodie, Pants, Shirt, Shoes, Shorts, Skirt, Top, T-Shirt)
- **Prediction Utilities**: Helper methods to get top predictions and filter by confidence

### 2. **Updated Image Search Service** (`lib/services/image_search_service.dart`)
Enhanced to use the ML model:
- Loads and initializes the TFLite model
- Classifies uploaded images using your trained model
- Matches predicted categories with products in your database
- Returns relevant products based on AI predictions
- Falls back to secondary predictions if no exact matches found

### 3. **Enhanced Image Search Controller** (`lib/controllers/image_search_controller.dart`)
Manages the image search state:
- Stores and displays model predictions
- Shows confidence scores for each prediction
- Handles model initialization on startup
- Properly disposes model on controller close

### 4. **Updated Image Search Screen** (`lib/screens/image_search_screen.dart`)
Visual improvements:
- **Prediction Display**: Shows top 3 AI predictions with confidence percentages
- **Color-coded Confidence**: 
  - Green: 70%+ (High confidence)
  - Orange: 40-69% (Medium confidence)
  - Red: Below 40% (Low confidence)
- **Enhanced Loading UI**: Shows AI analysis in progress
- **Better User Feedback**: Clear notifications about predictions

## How It Works

### User Flow:
1. User uploads an image (camera or gallery)
2. TFLite model analyzes the image
3. Model returns predictions (e.g., "Dress: 85%", "Skirt: 12%", "Top: 3%")
4. System shows predictions to user
5. System searches for products matching the predicted category
6. Results are displayed in a grid

### Example Prediction Flow:
```
Image Upload → TFLite Analysis → Predictions
                                   ↓
                    "Dress: 85%, Top: 10%, Skirt: 5%"
                                   ↓
              Search products with category "Dress"
                                   ↓
              Display matching products in grid
```

## Model Information

### Your Trained Model:
- **File**: `assets/models/model_unquant.tflite`
- **Labels**: `assets/models/labels.txt`
- **Categories**: 10 fashion categories
  - Dress, Hat, Hoodie, Pants, Shirt, Shoes, Shorts, Skirt, Top, T-Shirt

### Model Input:
- Image is automatically resized to model's expected dimensions
- Normalization applied (mean: 0.0, std: 255.0)
- Supports JPEG, PNG, and other common formats

### Model Output:
- Top 5 predictions with confidence scores
- Minimum confidence threshold: 10%
- Results sorted by confidence (highest first)

## Setup Instructions

### 1. Install Dependencies
Run this command to install the new `image` package:
```bash
flutter pub get
```

### 2. Verify Assets
Ensure these files exist:
- ✓ `assets/models/model_unquant.tflite`
- ✓ `assets/models/labels.txt`

### 3. Run the App
```bash
flutter run
```

### 4. Test the Feature
1. Navigate to Image Search screen
2. Upload a fashion item image
3. Watch the AI predictions appear
4. See matched products based on predictions

## Product Matching Logic

The system matches predictions to products using:
1. **Exact Category Match**: Product category matches predicted label
2. **Name Match**: Product name contains predicted label
3. **Partial Match**: Predicted label contains product category
4. **Fallback**: If no matches, shows secondary predictions
5. **Final Fallback**: Random products if no category matches

### Example:
```
Prediction: "Dress" (85% confidence)
↓
Search products where:
- category == "Dress" OR
- name.contains("dress") OR
- "dress".contains(category)
↓
Return matching products (up to 10)
```

## Customization Options

### Adjust Confidence Threshold
In `tflite_model_service.dart`, change the threshold:
```dart
threshold: 0.1,  // Change from 10% to your preferred value
```

### Change Number of Results
In `tflite_model_service.dart`:
```dart
numResults: 5,  // Change from 5 to get more/fewer predictions
```

### Modify Product Limit
In `image_search_service.dart`:
```dart
return matchingProducts.take(10).toList();  // Change 10 to your preference
```

### Adjust Prediction Display
In `image_search_screen.dart`:
```dart
...controller.predictions.take(3).map(...)  // Change 3 to show more/fewer predictions
```

## Performance Tips

1. **Model Loading**: Model loads once on app startup (in controller's `onInit`)
2. **Async Processing**: Image classification runs asynchronously to not block UI
3. **Caching**: Model stays in memory until app closes
4. **GPU Delegate**: Currently disabled; enable for faster inference on supported devices

### Enable GPU Acceleration (Optional):
In `tflite_model_service.dart`:
```dart
useGpuDelegate: true,  // Change from false to true
```

## Troubleshooting

### Model Not Loading
- Check if assets are properly declared in `pubspec.yaml`
- Verify file paths are correct
- Check console logs for error messages

### No Predictions Returned
- Ensure image is valid and not corrupted
- Check if model file is compatible with TFLite v2
- Verify labels.txt format is correct

### Products Not Matching
- Ensure products in database have proper categories
- Check category names match label names
- Review matching logic in `image_search_service.dart`

### Low Confidence Predictions
- May indicate image quality issues
- Consider retraining model with more data
- Adjust threshold to be more permissive

## Future Enhancements

Consider these improvements:
1. **Better Product Matching**: Use embeddings instead of text matching
2. **Image Preprocessing**: Add image enhancement before classification
3. **Model Caching**: Save predictions to avoid re-processing same images
4. **Batch Processing**: Process multiple images at once
5. **Online Model Updates**: Download updated models from server
6. **A/B Testing**: Compare different models' performance

## Technical Details

### Dependencies Added:
- `image: ^4.0.17` - Image processing for TFLite

### New Files Created:
- `lib/services/tflite_model_service.dart` - TFLite model handler

### Modified Files:
- `lib/services/image_search_service.dart` - Added ML integration
- `lib/controllers/image_search_controller.dart` - Added prediction state
- `lib/screens/image_search_screen.dart` - Added prediction UI
- `lib/utils/logger.dart` - Added success and warning methods
- `pubspec.yaml` - Added image package

## Support

For issues or questions:
1. Check console logs for detailed error messages
2. Verify all setup steps completed
3. Test with different images to isolate issues
4. Review the troubleshooting section above

---

**Happy Coding! 🚀**
