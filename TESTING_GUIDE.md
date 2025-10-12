# 🧪 Testing Guide: Verify Real Model is Working

## Quick Verification Steps

### 1. **Check App Logs** (Most Important)
When you run the app on Android/iOS, look for these log messages:

#### ✅ **Real Model Working** - Look for:
```
✅ "TFLite model initialized successfully"
✅ "Model loaded successfully with 10 labels"
✅ "Model input shape: [1, 224, 224, 3]" (or similar dimensions)
✅ "Model predictions: Dress: 78.5%, Top: 15.2%, Skirt: 3.1%"
```

#### ❌ **Still Using Mock** - You'll see:
```
❌ "Using mock predictions - real model not available"
❌ "TFLite not available - returning mock predictions"
```

### 2. **Test With Different Images**

#### Test Image 1: Dress
Upload a clear dress image, you should get:
- **Real Model**: `Dress: 70-95%`, other categories lower
- **Mock Model**: Always `Dress: 25%`, `Top: 20%`, `Shirt: 15%`

#### Test Image 2: Shoes
Upload a shoe image, you should get:
- **Real Model**: `Shoes: 60-90%`, dress/shirt categories lower
- **Mock Model**: Same `Dress: 25%`, `Top: 20%`, `Shirt: 15%`

#### Test Image 3: Non-Fashion Item
Upload a car/landscape/food image, you should get:
- **Real Model**: Low confidence across all categories (10-30%)
- **Mock Model**: Same fixed results

### 3. **Check Confidence Scores**

| Scenario | Real Model | Mock Model |
|----------|------------|------------|
| Perfect dress image | 80-95% | Always 25% |
| Unclear fashion item | 30-60% | Always 25% |
| Non-fashion image | 10-30% | Always 25% |
| Varies by image | ✅ Yes | ❌ No |

## Platform Testing

### Android Device Testing
```bash
# Build and install on Android device
flutter build apk --debug
flutter install
```

**Expected:** Real model predictions with varying results

### iOS Device Testing  
```bash
# Build and install on iOS device
flutter build ios --debug
# Install via Xcode
```

**Expected:** Real model predictions with varying results

### Web Testing
```bash
flutter run -d chrome
```

**Expected:** Mock predictions with warning logs

## Debugging Common Issues

### Issue: Still Getting Mock Predictions on Mobile

**Possible Causes:**
1. Model file missing from assets
2. Insufficient device memory
3. TFLite package not properly installed
4. App running on web instead of mobile

**Solutions:**
```bash
# 1. Verify assets
ls -la assets/models/
# Should show: model_unquant.tflite (~25MB), labels.txt

# 2. Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug

# 3. Check device logs
flutter logs
```

### Issue: App Crashes on Image Selection

**Possible Causes:**
1. Model file corrupted
2. Memory issues
3. Image processing errors

**Solutions:**
1. Re-download model file
2. Test with smaller images
3. Check error logs for specific issues

## Manual Testing Checklist

### ✅ Before Testing
- [ ] Android/iOS device connected
- [ ] App built and installed successfully
- [ ] Model files exist in `assets/models/`

### ✅ During Testing
- [ ] App starts without crashes
- [ ] Model loading logs appear on startup
- [ ] Image picker works (camera/gallery)
- [ ] Predictions appear after image selection
- [ ] Different images give different results
- [ ] Confidence scores vary realistically

### ✅ After Testing
- [ ] Real model predictions confirmed
- [ ] Product search returns relevant results
- [ ] No mock prediction warnings on mobile
- [ ] Web version still works with mock data

## Expected Performance

### Real Model Performance:
- **Startup**: +2 seconds (model loading)
- **First prediction**: 3-5 seconds
- **Subsequent predictions**: 1-2 seconds
- **Memory usage**: +50-100MB

### Mock Model Performance:
- **All predictions**: Instant
- **Memory usage**: Minimal

## Success Criteria

Your fix is successful when:

1. **✅ Different images produce different predictions**
2. **✅ Confidence scores vary realistically (not always 25%, 20%, 15%)**
3. **✅ Logs show "Model loaded successfully" on mobile**
4. **✅ Fashion items get high confidence in correct categories**
5. **✅ Non-fashion items get low confidence across all categories**

## Quick Test Commands

```bash
# Build for Android and check logs
flutter build apk --debug && flutter install && flutter logs

# Run on web to verify mock fallback
flutter run -d chrome

# Run tests
flutter test test/model_test.dart
```

## Contact for Issues

If you're still seeing mock predictions after following this guide:

1. Share the startup logs (first 30 seconds)
2. Share prediction results for 2-3 different images
3. Confirm you're testing on Android/iOS (not web)
4. Verify model file exists and size (~25MB)

**The real model should now be working on mobile devices!** 🎉