import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

enum Environment {
  dev,     // Local (emulator or real device)
  ngrok,   // Temporary public URL for testing
  prod,    // Hosted backend
}

class RuntimeConfig {
  Environment _environment = Environment.dev;

  // Singleton pattern
  static final RuntimeConfig _instance = RuntimeConfig._internal();
  factory RuntimeConfig() => _instance;
  RuntimeConfig._internal();

  // Detect platform (web, emulator, device)
  bool get _isEmulator =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android);

  // ✅ Dynamically get backend URL
  String get backendUrl {
    switch (_environment) {
      case Environment.dev:
        // Emulator = use 10.0.2.2, Real device = use WiFi IP
        final localUrl = _isEmulator
            ? "http://10.0.2.2:4000"
            : "http://192.168.0.xxx:4000"; // replace with your PC IP
        return localUrl;

      case Environment.ngrok:
        return "https://abcd1234.ngrok.io"; // <--- your ngrok tunnel

      case Environment.prod:
        return "https://greentalkies-backend.up.railway.app"; // hosted backend
    }
  }

  // Allow dynamic switching
  void setEnvironment(Environment env) {
    _environment = env;
  }

  Environment get environment => _environment;
}

// 🔧 Optional: Simple app-wide access
class AppConfig {
  static const bool isProduction = false; // change for release builds

  static String get backendUrl {
    if (isProduction) {
      return RuntimeConfig().backendUrl; // prod or hosted
    } else {
      return RuntimeConfig().backendUrl; // dev or ngrok
    }
  }
}
