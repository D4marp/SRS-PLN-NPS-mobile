import 'package:flutter/material.dart';

import '../utils/app_version.dart';

class AppVersionLabel extends StatelessWidget {
  final TextStyle? style;
  final TextAlign textAlign;

  const AppVersionLabel({
    super.key,
    this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AppVersion.loadDisplayLabel(),
      builder: (context, snapshot) {
        final label = snapshot.data;
        if (label == null || label.isEmpty) {
          return const SizedBox.shrink();
        }

        return Text(
          label,
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}
