import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendHelper {
  static String? _baseUrl;

  /// Initialize backend URL (call at app startup)
  static Future<void> init({int port = 4000}) async {
    if (kIsWeb) {
      _baseUrl = 'http://localhost:$port';
    } else {
      final info = NetworkInfo();
      String? wifiIp = await info.getWifiIP();
      _baseUrl = wifiIp != null ? 'http://$wifiIp:$port' : 'http://10.0.2.2:$port';
    }
    print('✅ Backend URL set to $_baseUrl');
  }

  /// Get backend URL
  static String get baseUrl {
    if (_baseUrl == null) {
      throw Exception('BackendHelper not initialized. Call BackendHelper.init() first.');
    }
    return _baseUrl!;
  }

  // -----------------------------
  // Generic GET
  // -----------------------------
  static Future<Map<String, dynamic>> get(String path,
      {int timeoutSeconds = 10}) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.get(url).timeout(Duration(seconds: timeoutSeconds));
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'data': null, 'error': e.toString()};
    }
  }

  // -----------------------------
  // Generic POST
  // -----------------------------
  static Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body, int timeoutSeconds = 10}) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: timeoutSeconds));
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'data': null, 'error': e.toString()};
    }
  }

  // -----------------------------
  // Process response
  // -----------------------------
  static Map<String, dynamic> _processResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': body, 'error': null};
    } else {
      return {
        'success': false,
        'data': body,
        'error': body != null && body['message'] != null
            ? body['message']
            : 'HTTP ${response.statusCode} error'
      };
    }
  }

  // -----------------------------
  // User APIs
  // -----------------------------
  static Future<Map<String, dynamic>> getUser(String userId) async {
    return get('/user/$userId');
  }

  static Future<Map<String, dynamic>> getImpact(String userId) async {
    return get('/user/$userId/impact');
  }

  // -----------------------------
  // Task APIs
  // -----------------------------
  static Future<Map<String, dynamic>> getTasks(String userId) async {
    return get('/tasks/$userId');
  }
}
