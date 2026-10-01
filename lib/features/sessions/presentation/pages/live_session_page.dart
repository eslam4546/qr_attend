import 'package:flutter/material.dart';

/// Placeholder — will be implemented in Step 5.5
class LiveSessionPage extends StatelessWidget {
  final String sessionId;

  const LiveSessionPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Live Session: $sessionId')),
    );
  }
}
