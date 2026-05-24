// IoT Status Widget
// lib/widgets/room_status_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iot_provider.dart';

class RoomStatusCard extends StatelessWidget {
  final String roomId;
  final String roomName;
  final VoidCallback? onRefresh;

  const RoomStatusCard({
    super.key,
    required this.roomId,
    required this.roomName,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<IoTProvider>(
      builder: (context, iotProvider, _) {
        final status = iotProvider.getRoomStatus(roomId);

        if (status == null) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roomName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Loading IoT status...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onRefresh != null)
                    IconButton(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                    ),
                ],
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan room name dan status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roomName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Device ID: ${status.deviceId}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _buildStatusBadge(status.isOccupied),
                        const SizedBox(height: 8),
                        _buildLockStatusBadge(status.doorLocked),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Environmental conditions
                Row(
                  children: [
                    Expanded(
                      child: _buildEnvironmentCard(
                        icon: Icons.thermostat,
                        label: 'Temperature',
                        value: '${status.temperature.toStringAsFixed(1)}°C',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildEnvironmentCard(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '${status.humidity.toStringAsFixed(0)}%',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Energy and light
                Row(
                  children: [
                    Expanded(
                      child: _buildEnvironmentCard(
                        icon: Icons.electric_bolt,
                        label: 'Power Usage',
                        value: '${status.energyUsage.toStringAsFixed(0)}W',
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildEnvironmentCard(
                        icon: Icons.light_mode,
                        label: 'Light Level',
                        value: '${status.lightLevel}%',
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Last update time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last update: ${_formatTime(status.lastUpdate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (onRefresh != null)
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: onRefresh,
                          icon: const Icon(Icons.refresh, size: 18),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool isOccupied) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOccupied ? Colors.red.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOccupied ? 'In Use' : 'Available',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isOccupied ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  Widget _buildLockStatusBadge(bool isLocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isLocked ? Colors.blue.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isLocked ? Icons.lock : Icons.lock_open,
            size: 12,
            color: isLocked ? Colors.blue : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isLocked ? 'Locked' : 'Unlocked',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.blue : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
