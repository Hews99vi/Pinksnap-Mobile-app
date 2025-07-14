# Image Search Feature - PinkSnap Fashion App

## Overview
The Image Search feature allows users to upload photos and find similar fashion items available in the store. This feature uses visual search technology to analyze uploaded images and match them with products in the catalog.

## Features Implemented

### 1. Image Upload Options
- **Camera Capture**: Take photos directly using the device camera
- **Gallery Selection**: Choose existing photos from the device gallery
- **Permission Handling**: Automatically requests and manages camera/storage permissions

### 2. User Interface Components

#### Home Screen Integration
- **Camera Button**: Added a prominent camera button in the app bar (where the red notification badge was in the original design)
- **Promo Card**: Added an attractive promotional card on the home screen to introduce the new feature
- **Visual Indicators**: Added a small orange badge to indicate this is a new feature

#### Dedicated Image Search Screen
- **Upload Section**: Clean interface for image upload with drag-and-drop style design
- **Image Preview**: Shows selected image with options to change or clear
- **Search Results Grid**: Displays similar products in a responsive grid layout
- **Search History**: Keeps track of previously searched images for quick access

### 3. Controllers and Services

#### ImageSearchController (`lib/controllers/image_search_controller.dart`)
- Manages image selection from camera/gallery
- Handles search state (loading, results, history)
- Provides methods for performing searches and managing results
- Includes error handling and user feedback

#### ImageSearchService (`lib/services/image_search_service.dart`)
- Prepared for ML model integration
- Currently returns mock data for demonstration
- Includes placeholder methods for actual API integration
- Structured to easily integrate with your ML backend

### 4. Reusable Components

#### ImageSearchButton (`lib/widgets/image_search_button.dart`)
- Reusable button component with gradient styling
- Can be used throughout the app
- Includes visual indicators for new feature

#### ImageSearchPromoCard (`lib/widgets/image_search_promo_card.dart`)
- Promotional card to highlight the feature
- Attractive gradient design matching app theme
- Can be placed on home screen or other locations

## File Structure
```
lib/
├── controllers/
│   └── image_search_controller.dart    # Main controller for image search
├── services/
│   └── image_search_service.dart       # Service for ML integration
├── screens/
│   └── image_search_screen.dart        # Main image search interface
└── widgets/
    ├── image_search_button.dart        # Reusable search button
    └── image_search_promo_card.dart     # Promotional card component
```

## Dependencies Added
```yaml
dependencies:
  image_picker: ^1.0.7          # For picking images from gallery/camera
  permission_handler: ^11.3.0   # For handling permissions
```

## Android Permissions
Added to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

## How It Works (Current Implementation)

1. **User Interface**: Users can access image search via:
   - Camera button in the home screen app bar
   - Promotional card on the home screen
   - Direct navigation to image search screen

2. **Image Selection**: 
   - Users choose between camera or gallery
   - App requests necessary permissions
   - Selected image is displayed with preview

3. **Search Process**:
   - Currently shows loading animation
   - Returns mock results from existing product catalog
   - Displays results in grid format

4. **Results Display**:
   - Shows similar products in responsive grid
   - Users can tap to view product details
   - Maintains search history for quick access

## ML Model Integration (Next Steps)

The `ImageSearchService` is prepared for ML model integration. To connect your ML model:

1. **Update the service endpoint**:
   ```dart
   final String baseUrl = 'https://your-ml-api-endpoint.com';
   ```

2. **Implement the actual API calls** (currently commented out):
   ```dart
   final request = http.MultipartRequest(
     'POST',
     Uri.parse('$baseUrl/search-similar'),
   );
   request.files.add(
     await http.MultipartFile.fromPath('image', imageFile.path),
   );
   ```

3. **Replace mock data** with actual API responses

## Usage Examples

### Adding Image Search Button to Any Screen
```dart
import '../widgets/image_search_button.dart';

// In your widget build method:
ImageSearchButton(
  size: 24,
  showLabel: true,
  margin: EdgeInsets.all(16),
)
```

### Accessing Image Search Controller
```dart
final ImageSearchController controller = Get.find<ImageSearchController>();

// Trigger search programmatically
controller.showImageSourceDialog();

// Access search results
Obx(() => Text('Found ${controller.searchResults.length} results'));
```

## Design Features

- **Modern UI**: Clean, modern interface matching the app's pink theme
- **Responsive Design**: Works on different screen sizes
- **Loading States**: Smooth loading animations and progress indicators
- **Error Handling**: User-friendly error messages and fallbacks
- **Accessibility**: Proper labels and semantic widgets

## Testing the Feature

1. Run the app: `flutter run`
2. Navigate to home screen
3. Tap the camera button in the app bar or the promotional card
4. Select an image from camera or gallery
5. View the mock search results
6. Test search history functionality

The feature is now ready for ML model integration and provides a complete user experience for image-based fashion search!
