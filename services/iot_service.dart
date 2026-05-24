// Milesight IoT Service
// lib/services/iot_service.dart

import 'package:dio/dio.dart';
import '../models/iot_models.dart';

class MilesightIoTService {
  // Milesight API Configuration
  static const String MILESIGHT_API_BASE = 'https://api.milesight.com/v1';
  static const String MQTT_BROKER = 'mqtt.milesight.com';
  static const int MQTT_PORT = 1883;
  static const int MQTT_TLS_PORT = 8883;

  late Dio _dio;
  String? _apiKey;
  String? _organizationId;

  // Simulated room statuses (untuk development/testing)
  final Map<String, RoomStatus> _cachedRoomStatuses = {};
  
  // Callbacks untuk real-time updates
  final Map<String, List<Function(RoomStatus)>> _roomStatusCallbacks = {};

  MilesightIoTService() {
    _dio = Dio(BaseOptions(
      baseUrl: MILESIGHT_API_BASE,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Add interceptor untuk API key
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_apiKey != null) {
            options.headers['Authorization'] = 'Bearer $_apiKey';
          }
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onError: (error, handler) {
          print('Milesight API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Initialize connection dengan Milesight IoT Cloud
  Future<bool> initialize({
    required String apiKey,
    required String organizationId,
  }) async {
    try {
      _apiKey = apiKey;
      _organizationId = organizationId;

      // Verify credentials dengan API test
      final response = await _dio.get(
        '/organizations/$organizationId/status',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Failed to initialize Milesight: $e');
      return false;
    }
  }

  /// Get real-time status untuk specific room
  Future<RoomStatus?> getRoomStatus(String roomId) async {
    try {
      // Check cached data first
      if (_cachedRoomStatuses.containsKey(roomId)) {
        return _cachedRoomStatuses[roomId];
      }

      final response = await _dio.get(
        '/organizations/$_organizationId/devices',
        queryParameters: {'room_id': roomId},
      );

      if (response.statusCode == 200) {
        final devices = response.data['data'] as List;
        
        // Aggregate sensor data menjadi RoomStatus
        Map<String, dynamic> aggregatedData = {
          'room_id': roomId,
          'occupancy': _getOccupancyFromDevices(devices),
          'temperature': _getTemperatureFromDevices(devices),
          'humidity': _getHumidityFromDevices(devices),
          'lock_status': _getDoorStatusFromDevices(devices),
          'light_level': _getLightLevelFromDevices(devices),
          'energy_usage': _getEnergyFromDevices(devices),
          'timestamp': DateTime.now().toIso8601String(),
          'device_id': roomId,
        };

        final status = RoomStatus.fromMilesight(aggregatedData);
        _cachedRoomStatuses[roomId] = status;
        
        return status;
      }
    } catch (e) {
      print('Error getting room status: $e');
    }
    return null;
  }

  /// Subscribe to real-time updates untuk specific room
  /// Returns a stream yang emit RoomStatus updates
  Stream<RoomStatus> subscribeToRoomStatus(String roomId) async* {
    try {
      // Simulate real-time updates menggunakan periodic fetches
      // Dalam production, gunakan MQTT untuk lebih efficient
      while (true) {
        final status = await getRoomStatus(roomId);
        if (status != null) {
          yield status;
          
          // Trigger callbacks
          if (_roomStatusCallbacks.containsKey(roomId)) {
            for (var callback in _roomStatusCallbacks[roomId]!) {
              callback(status);
            }
          }
        }
        
        // Wait 5 seconds sebelum fetch lagi
        await Future.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      print('Error in room status subscription: $e');
      rethrow;
    }
  }

  /// Unlock door untuk specific room
  Future<bool> unlockDoor({
    required String roomId,
    required String bookingId,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '/organizations/$_organizationId/devices/$roomId/commands',
        data: {
          'command': 'unlock',
          'booking_id': bookingId,
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        // Log access
        await _logDoorAccess(
          roomId: roomId,
          bookingId: bookingId,
          userId: userId,
          accessType: 'unlock',
          successful: true,
        );
        return true;
      }
    } catch (e) {
      print('Error unlocking door: $e');
      await _logDoorAccess(
        roomId: roomId,
        bookingId: bookingId,
        userId: userId,
        accessType: 'unlock',
        successful: false,
      );
    }
    return false;
  }

  /// Lock door untuk specific room
  Future<bool> lockDoor({
    required String roomId,
    required String bookingId,
  }) async {
    try {
      final response = await _dio.post(
        '/organizations/$_organizationId/devices/$roomId/commands',
        data: {
          'command': 'lock',
          'booking_id': bookingId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error locking door: $e');
    }
    return false;
  }

  /// Get analytics untuk specific room
  Future<RoomAnalytics?> getRoomAnalytics({
    required String roomId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/organizations/$_organizationId/analytics/rooms/$roomId',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return RoomAnalytics.fromJson(response.data['data']);
      }
    } catch (e) {
      print('Error getting room analytics: $e');
    }
    return null;
  }

  /// Get all devices untuk organization
  Future<List<IoTDevice>> getAllDevices() async {
    try {
      final response = await _dio.get(
        '/organizations/$_organizationId/devices',
      );

      if (response.statusCode == 200) {
        final devices = response.data['data'] as List;
        return devices.map((d) => IoTDevice.fromJson(d)).toList();
      }
    } catch (e) {
      print('Error getting devices: $e');
    }
    return [];
  }

  /// Get active alerts
  Future<List<IoTAlert>> getActiveAlerts() async {
    try {
      final response = await _dio.get(
        '/organizations/$_organizationId/alerts',
        queryParameters: {'resolved': false},
      );

      if (response.statusCode == 200) {
        final alerts = response.data['data'] as List;
        return alerts.map((a) => IoTAlert.fromJson(a)).toList();
      }
    } catch (e) {
      print('Error getting alerts: $e');
    }
    return [];
  }

  /// Resolve alert
  Future<bool> resolveAlert({
    required String alertId,
    required String resolvedBy,
  }) async {
    try {
      final response = await _dio.put(
        '/organizations/$_organizationId/alerts/$alertId',
        data: {
          'resolved': true,
          'resolved_by': resolvedBy,
          'resolved_at': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error resolving alert: $e');
    }
    return false;
  }

  /// Set control command untuk device
  Future<bool> sendDeviceCommand({
    required String deviceId,
    required String command,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final response = await _dio.post(
        '/organizations/$_organizationId/devices/$deviceId/commands',
        data: {
          'command': command,
          'parameters': parameters,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending device command: $e');
    }
    return false;
  }

  // ==================== PRIVATE HELPER METHODS ====================

  Future<void> _logDoorAccess({
    required String roomId,
    required String bookingId,
    required String userId,
    required String accessType,
    required bool successful,
  }) async {
    try {
      await _dio.post(
        '/organizations/$_organizationId/access-logs',
        data: {
          'room_id': roomId,
          'booking_id': bookingId,
          'user_id': userId,
          'access_type': accessType,
          'successful': successful,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error logging door access: $e');
    }
  }

  int _getOccupancyFromDevices(List devices) {
    try {
      final occupancySensor = devices.firstWhere(
        (d) => d['device_type'] == 'occupancy_sensor',
        orElse: () => null,
      );
      return occupancySensor?['value'] == 1 ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  double _getTemperatureFromDevices(List devices) {
    try {
      final tempSensor = devices.firstWhere(
        (d) => d['device_type'] == 'temperature_sensor',
        orElse: () => null,
      );
      return (tempSensor?['value'] ?? 20.0).toDouble();
    } catch (e) {
      return 20.0;
    }
  }

  double _getHumidityFromDevices(List devices) {
    try {
      final humiditySensor = devices.firstWhere(
        (d) => d['device_type'] == 'humidity_sensor',
        orElse: () => null,
      );
      return (humiditySensor?['value'] ?? 50.0).toDouble();
    } catch (e) {
      return 50.0;
    }
  }

  String _getDoorStatusFromDevices(List devices) {
    try {
      final lockDevice = devices.firstWhere(
        (d) => d['device_type'] == 'smart_lock',
        orElse: () => null,
      );
      return lockDevice?['status'] == 'locked' ? 'locked' : 'unlocked';
    } catch (e) {
      return 'unknown';
    }
  }

  int _getLightLevelFromDevices(List devices) {
    try {
      final lightSensor = devices.firstWhere(
        (d) => d['device_type'] == 'light_sensor',
        orElse: () => null,
      );
      return (lightSensor?['value'] ?? 0).toInt();
    } catch (e) {
      return 0;
    }
  }

  double _getEnergyFromDevices(List devices) {
    try {
      final energyMeter = devices.firstWhere(
        (d) => d['device_type'] == 'energy_meter',
        orElse: () => null,
      );
      return (energyMeter?['value'] ?? 0.0).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  /// Register callback untuk room status updates
  void registerStatusCallback(
    String roomId,
    Function(RoomStatus) callback,
  ) {
    if (!_roomStatusCallbacks.containsKey(roomId)) {
      _roomStatusCallbacks[roomId] = [];
    }
    _roomStatusCallbacks[roomId]!.add(callback);
  }

  /// Unregister callback
  void unregisterStatusCallback(
    String roomId,
    Function(RoomStatus) callback,
  ) {
    if (_roomStatusCallbacks.containsKey(roomId)) {
      _roomStatusCallbacks[roomId]!.remove(callback);
    }
  }

  /// Clear all cached data
  void clearCache() {
    _cachedRoomStatuses.clear();
  }

  /// Disconnect dari service
  void disconnect() {
    _cachedRoomStatuses.clear();
    _roomStatusCallbacks.clear();
    _apiKey = null;
    _organizationId = null;
  }
}
