import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../utils/api_config.dart';

class HealthPingService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static Timer? _pingTimer;
  static String? _clientId;

  static Future<String> getClientId() async {
    if (_clientId != null) return _clientId!;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('health_client_id');
      if (id == null) {
        id = const Uuid().v4();
        await prefs.setString('health_client_id', id);
      }
      _clientId = id;
    } catch (e) {
      debugPrint('Warning: SharedPreferences failed: $e, using ephemeral UUID');
      _clientId = const Uuid().v4();
    }
    return _clientId!;
  }

  static Future<void> start() async {
    if (_pingTimer != null) return; // Already running

    debugPrint('🚀 HealthPingService started...');
    
    // Initial ping immediately
    _sendPing();

    // Periodic ping every 10 seconds
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _sendPing();
    });
  }

  static Future<void> _sendPing() async {
    try {
      final clientId = await getClientId();
      final url = '${ApiConfig.baseUrl}/health/ping';
      
      final response = await _dio.post(
        url,
        data: {
          'clientId': clientId,
          'clientType': 'mobile',
          'clientName': 'Mobile App',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Client-Type': 'mobile',
            'X-Client-Name': 'Mobile App',
          },
        ),
      );
      
      debugPrint('🔔 Health ping sent to backend: status ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Failed to send health ping: $e');
    }
  }

  static void stop() {
    _pingTimer?.cancel();
    _pingTimer = null;
    debugPrint('🛑 HealthPingService stopped.');
  }
}
