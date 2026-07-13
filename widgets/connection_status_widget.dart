import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/websocket_service.dart';

class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({super.key});

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _RoomConnectionStatusDot extends StatefulWidget {
  final Color color;
  final bool animate;

  const _RoomConnectionStatusDot({
    required this.color,
    required this.animate,
  });

  @override
  State<_RoomConnectionStatusDot> createState() => _RoomConnectionStatusDotState();
}

class _RoomConnectionStatusDotState extends State<_RoomConnectionStatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _RoomConnectionStatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animate ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  static const _channel = MethodChannel('com.example.bookify_rooms/wifi');

  Future<void> _openWifiSettings() async {
    try {
      await _channel.invokeMethod('openWifiSettings');
    } on PlatformException catch (e) {
      debugPrint("Failed to open WiFi settings: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: WebSocketService.connectionState,
      builder: (context, status, _) {
        Color dotColor;
        String statusText;
        bool animateDot = false;

        switch (status) {
          case 'connected':
            dotColor = const Color(0xFF2E7D32); // Green
            statusText = 'Terhubung';
            animateDot = false;
            break;
          case 'connecting':
            dotColor = const Color(0xFFEF6C00); // Amber/Orange
            statusText = 'Menghubungkan...';
            animateDot = true;
            break;
          case 'disconnected':
          default:
            dotColor = const Color(0xFFC62828); // Red
            statusText = 'Koneksi Terputus';
            animateDot = true;
            break;
        }

        final mainContent = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoomConnectionStatusDot(
                color: dotColor,
                animate: animateDot,
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );

        if (status == 'disconnected') {
          return GestureDetector(
            onTap: _openWifiSettings,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: mainContent,
            ),
          );
        }

        final isConnected = status == 'connected';
        return Opacity(
          opacity: isConnected ? 0.35 : 1.0,
          child: mainContent,
        );
      },
    );
  }
}
