import 'package:network_info_plus/network_info_plus.dart';

class NetworkHelper {
  static String? _baseUrl;

  /// Initialize dynamic backend URL from Wi-Fi IP
  static Future<void> init() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    if (wifiIP != null) {
      _baseUrl = 'http://$wifiIP:4000';
    } else {
      throw Exception('Could not get Wi-Fi IP');
    }
  }

  static String get baseUrl {
    if (_baseUrl == null) throw Exception('NetworkHelper not initialized');
    return _baseUrl!;
  }

  static String get plantsUrl => '$baseUrl/plants';
}
