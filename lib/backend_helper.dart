import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'config.dart';

class BackendHelper {
  // Singleton pattern
  static final BackendHelper _instance = BackendHelper._internal();
  factory BackendHelper() => _instance;
  BackendHelper._internal();

  String? _backendUrl;

  /// Get backend URL, auto-detect emulator/device or use production
  Future<String> getBackendUrl() async {
    // If already initialized, return it
    if (_backendUrl != null) return _backendUrl!;

    final info = NetworkInfo();
    String baseUrl = '10.0.2.2'; // Default for Android emulator

    try {
      if (kIsWeb) {
        baseUrl = 'localhost';
      } else {
        final wifiIp = await info.getWifiIP();
        if (wifiIp != null && !wifiIp.startsWith('10.0.2.')) {
          // Physical device on same Wi-Fi
          baseUrl = wifiIp;
        } else {
          // Emulator fallback
          baseUrl = '10.0.2.2';
        }
      }
    } catch (e) {
      print("⚠️ Error detecting IP: $e, fallback to emulator default");
    }

    // Use RuntimeConfig to finalize URL based on environment
    final runtimeConfig = RuntimeConfig();
    if (runtimeConfig.environment == Environment.prod) {
      _backendUrl = runtimeConfig.backendUrl;
    } else {
      _backendUrl = 'http://$baseUrl:4000';
    }

    print("✅ Backend URL resolved: $_backendUrl");
    return _backendUrl!;
  }
}
