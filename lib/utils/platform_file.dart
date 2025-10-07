// Cross-platform file abstraction for web compatibility
// On web, XFile from image_picker will be used directly
// On mobile, dart:io File will be used

import 'package:flutter/foundation.dart' show kIsWeb;
export 'dart:io' if (dart.library.html) 'package:image_picker/image_picker.dart' show XFile;

// Helper to check if we're on a mobile platform
bool get isMobilePlatform => !kIsWeb;
