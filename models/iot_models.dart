// IoT Models untuk Milesight Integration
// lib/models/iot_models.dart

class RoomStatus {
  final String roomId;
  final bool isOccupied;
  final double temperature;
  final double humidity;
  final bool doorLocked;
  final int lightLevel;
  final double energyUsage; // Watts
  final DateTime lastUpdate;
  final String deviceId;

  RoomStatus({
    required this.roomId,
    required this.isOccupied,
    required this.temperature,
    required this.humidity,
    required this.doorLocked,
    required this.lightLevel,
    required this.energyUsage,
    required this.lastUpdate,
    required this.deviceId,
  });

  // Parse dari Milesight MQTT message
  factory RoomStatus.fromMilesight(Map<String, dynamic> json) {
    return RoomStatus(
      roomId: json['room_id'] ?? 'unknown',
      isOccupied: json['occupancy'] == 1 || json['occupancy'] == true,
      temperature: (json['temperature'] ?? 20.0).toDouble(),
      humidity: (json['humidity'] ?? 50.0).toDouble(),
      doorLocked: json['lock_status'] == 'locked' || json['lock_status'] == 1,
      lightLevel: json['light_level'] ?? 0,
      energyUsage: (json['energy_usage'] ?? 0.0).toDouble(),
      lastUpdate: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      deviceId: json['device_id'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'isOccupied': isOccupied,
        'temperature': temperature,
        'humidity': humidity,
        'doorLocked': doorLocked,
        'lightLevel': lightLevel,
        'energyUsage': energyUsage,
        'lastUpdate': lastUpdate.toIso8601String(),
        'deviceId': deviceId,
      };
}

class RoomAnalytics {
  final String roomId;
  final double totalEnergyUsed; // kWh
  final int totalHoursBooked;
  final double averageOccupancy; // percentage
  final double averageTemperature;
  final List<TemperatureReading> temperatureLog;
  final DateTime periodStart;
  final DateTime periodEnd;

  RoomAnalytics({
    required this.roomId,
    required this.totalEnergyUsed,
    required this.totalHoursBooked,
    required this.averageOccupancy,
    required this.averageTemperature,
    required this.temperatureLog,
    required this.periodStart,
    required this.periodEnd,
  });

  factory RoomAnalytics.fromJson(Map<String, dynamic> json) {
    return RoomAnalytics(
      roomId: json['room_id'],
      totalEnergyUsed: (json['total_energy_used'] ?? 0.0).toDouble(),
      totalHoursBooked: json['total_hours_booked'] ?? 0,
      averageOccupancy: (json['average_occupancy'] ?? 0.0).toDouble(),
      averageTemperature: (json['average_temperature'] ?? 20.0).toDouble(),
      temperatureLog: (json['temperature_log'] as List?)
              ?.map((e) => TemperatureReading.fromJson(e))
              .toList() ??
          [],
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
    );
  }
}

class TemperatureReading {
  final DateTime timestamp;
  final double temperature;
  final double humidity;

  TemperatureReading({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
  });

  factory TemperatureReading.fromJson(Map<String, dynamic> json) {
    return TemperatureReading(
      timestamp: DateTime.parse(json['timestamp']),
      temperature: (json['temperature'] ?? 20.0).toDouble(),
      humidity: (json['humidity'] ?? 50.0).toDouble(),
    );
  }
}

class DoorAccessLog {
  final String roomId;
  final String userId;
  final String bookingId;
  final DateTime accessTime;
  final String accessType; // 'unlock', 'lock', 'forced_open'
  final bool successful;
  final String? deviceId;

  DoorAccessLog({
    required this.roomId,
    required this.userId,
    required this.bookingId,
    required this.accessTime,
    required this.accessType,
    required this.successful,
    this.deviceId,
  });

  factory DoorAccessLog.fromJson(Map<String, dynamic> json) {
    return DoorAccessLog(
      roomId: json['room_id'],
      userId: json['user_id'],
      bookingId: json['booking_id'],
      accessTime: DateTime.parse(json['access_time']),
      accessType: json['access_type'],
      successful: json['successful'],
      deviceId: json['device_id'],
    );
  }
}

class IoTDevice {
  final String deviceId;
  final String deviceType; // 'sensor', 'lock', 'controller'
  final String model;
  final String roomId;
  final String status; // 'active', 'inactive', 'maintenance'
  final int batteryLevel;
  final String signalStrength;
  final DateTime lastHeartbeat;

  IoTDevice({
    required this.deviceId,
    required this.deviceType,
    required this.model,
    required this.roomId,
    required this.status,
    required this.batteryLevel,
    required this.signalStrength,
    required this.lastHeartbeat,
  });

  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    return IoTDevice(
      deviceId: json['device_id'],
      deviceType: json['device_type'],
      model: json['model'],
      roomId: json['room_id'],
      status: json['status'],
      batteryLevel: json['battery_level'] ?? 100,
      signalStrength: json['signal_strength'] ?? '-90dBm',
      lastHeartbeat: DateTime.parse(json['last_heartbeat']),
    );
  }
}

class IoTAlert {
  final String alertId;
  final String roomId;
  final String alertType; // 'temperature', 'battery', 'occupancy', 'maintenance'
  final String severity; // 'low', 'medium', 'high', 'critical'
  final String message;
  final DateTime createdAt;
  final bool resolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  IoTAlert({
    required this.alertId,
    required this.roomId,
    required this.alertType,
    required this.severity,
    required this.message,
    required this.createdAt,
    required this.resolved,
    this.resolvedBy,
    this.resolvedAt,
  });

  factory IoTAlert.fromJson(Map<String, dynamic> json) {
    return IoTAlert(
      alertId: json['alert_id'],
      roomId: json['room_id'],
      alertType: json['alert_type'],
      severity: json['severity'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      resolved: json['resolved'] ?? false,
      resolvedBy: json['resolved_by'],
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
    );
  }
}
