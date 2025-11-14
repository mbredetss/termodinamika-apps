// storage_service.dart - Main entry point with conditional imports
export 'storage_interface.dart';
export 'storage_service_stub.dart'
    if (dart.library.js) 'storage_service_web.dart';