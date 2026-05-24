// IoT Provider untuk state management
// lib/providers/iot_provider.dart

import 'package:flutter/material.dart';
import '../services/iot_service.dart';
import '../models/iot_models.dart';

class IoTProvider extends ChangeNotifier {
  final MilesightIoTService _iotService = MilesightIoTService();

  // State
  bool _isInitialized = false;
  bool _isConnected = false;
  Map<String, RoomStatus> _roomStatuses = {};
  List<IoTDevice> _devices = [];
  List<IoTAlert> _activeAlerts = [];
  String? _errorMessage;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;
  Map<String, RoomStatus> get roomStatuses => _roomStatuses;
  List<IoTDevice> get devices => _devices;
  List<IoTAlert> get activeAlerts => _activeAlerts;
  String? get errorMessage => _errorMessage;

  RoomStatus? getRoomStatus(String roomId) => _roomStatuses[roomId];
  IoTDevice? getDevice(String deviceId) {
    try {
      return _devices.firstWhere((d) => d.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  /// Initialize IoT connection dengan Milesight
  Future<bool> initializeIoT({
    required String apiKey,
    required String organizationId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _iotService.initialize(
        apiKey: apiKey,
        organizationId: organizationId,
      );

      if (success) {
        _isInitialized = true;
        _isConnected = true;
        
        // Load initial data
        await _loadAllDevices();
        await _loadAllAlerts();
        
        notifyListeners();
        return true;
      } else {
        _setError('Failed to initialize Milesight IoT connection');
        return false;
      }
    } catch (e) {
      _setError('Error initializing IoT: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get real-time status untuk specific room
  Future<RoomStatus?> getRoomStatusFromCloud(String roomId) async {
    try {
      final status = await _iotService.getRoomStatus(roomId);
      if (status != null) {
        _roomStatuses[roomId] = status;
        notifyListeners();
      }
      return status;
    } catch (e) {
      _setError('Error fetching room status: $e');
      return null;
    }
  }

  /// Subscribe ke real-time updates untuk specific room
  void subscribeToRoom(String roomId) {
    try {
      _iotService.subscribeToRoomStatus(roomId).listen(
        (status) {
          _roomStatuses[roomId] = status;
          notifyListeners();
        },
        onError: (error) {
          _setError('Error in room subscription: $error');
        },
      );
    } catch (e) {
      _setError('Error subscribing to room: $e');
    }
  }

  /// Unlock door untuk booking
  Future<bool> unlockRoomDoor({
    required String roomId,
    required String bookingId,
    required String userId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _iotService.unlockDoor(
        roomId: roomId,
        bookingId: bookingId,
        userId: userId,
      );

      if (success) {
        // Update local status
        if (_roomStatuses.containsKey(roomId)) {
          final updatedStatus = _roomStatuses[roomId]!;
          _roomStatuses[roomId] = RoomStatus(
            roomId: updatedStatus.roomId,
            isOccupied: updatedStatus.isOccupied,
            temperature: updatedStatus.temperature,
            humidity: updatedStatus.humidity,
            doorLocked: false, // Door is now unlocked
            lightLevel: updatedStatus.lightLevel,
            energyUsage: updatedStatus.energyUsage,
            lastUpdate: DateTime.now(),
            deviceId: updatedStatus.deviceId,
          );
        }
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError('Error unlocking door: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Lock door setelah checkout
  Future<bool> lockRoomDoor({
    required String roomId,
    required String bookingId,
  }) async {
    try {
      _setLoading(true);
      final success = await _iotService.lockDoor(
        roomId: roomId,
        bookingId: bookingId,
      );

      if (success) {
        // Update local status
        if (_roomStatuses.containsKey(roomId)) {
          final updatedStatus = _roomStatuses[roomId]!;
          _roomStatuses[roomId] = RoomStatus(
            roomId: updatedStatus.roomId,
            isOccupied: updatedStatus.isOccupied,
            temperature: updatedStatus.temperature,
            humidity: updatedStatus.humidity,
            doorLocked: true, // Door is now locked
            lightLevel: updatedStatus.lightLevel,
            energyUsage: updatedStatus.energyUsage,
            lastUpdate: DateTime.now(),
            deviceId: updatedStatus.deviceId,
          );
        }
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError('Error locking door: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get analytics untuk room
  Future<RoomAnalytics?> getRoomAnalytics({
    required String roomId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _iotService.getRoomAnalytics(
        roomId: roomId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _setError('Error fetching analytics: $e');
      return null;
    }
  }

  // ==================== PRIVATE METHODS ====================

  Future<void> _loadAllDevices() async {
    try {
      _devices = await _iotService.getAllDevices();
      notifyListeners();
    } catch (e) {
      _setError('Error loading devices: $e');
    }
  }

  Future<void> _loadAllAlerts() async {
    try {
      _activeAlerts = await _iotService.getActiveAlerts();
      notifyListeners();
    } catch (e) {
      _setError('Error loading alerts: $e');
    }
  }

  Future<bool> resolveAlert(String alertId, String userId) async {
    try {
      final success = await _iotService.resolveAlert(
        alertId: alertId,
        resolvedBy: userId,
      );

      if (success) {
        _activeAlerts.removeWhere((a) => a.alertId == alertId);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError('Error resolving alert: $e');
      return false;
    }
  }

  void _setLoading(bool value) {
    // Optional: track loading state if needed
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    print('IoTProvider Error: $message');
  }

  /// Disconnect dari IoT service
  void disconnect() {
    _iotService.disconnect();
    _isInitialized = false;
    _isConnected = false;
    _roomStatuses.clear();
    _devices.clear();
    _activeAlerts.clear();
    notifyListeners();
  }

  /// Clear cache
  void clearCache() {
    _iotService.clearCache();
    _roomStatuses.clear();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
