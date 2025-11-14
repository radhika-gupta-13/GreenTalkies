import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:network_info_plus/network_info_plus.dart';

class BackendConfig {
  // Returns the current server IP (emulator, device, or web)
  static Future<String> getServerIp() async {
    String baseIp = '10.0.2.2'; // default emulator IP

    try {
      if (kIsWeb) {
        baseIp = 'localhost';
      } else {
        final wifiIp = await NetworkInfo().getWifiIP();
        if (wifiIp != null && !wifiIp.startsWith('10.0.2.')) {
          // Physical device on same Wi-Fi
          baseIp = wifiIp;
        }
      }
    } catch (e) {
      print('⚠️ Error detecting IP: $e, falling back to $baseIp');
    }

    return baseIp;
  }

  // Returns full API base URL
  static String apiBase(String ip) {
    return 'http://$ip:4000'; // your local dev port
  }
}
