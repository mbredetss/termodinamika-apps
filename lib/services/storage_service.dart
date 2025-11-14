// storage_service.dart - Main entry point with conditional imports

import 'storage_service_stub.dart'
    // Conditional import for web
    if (dart.library.js) 'storage_service_web.dart';

export 'storage_interface.dart';
export 'storage_service_stub.dart'
    if (dart.library.js) 'storage_service_web.dart';