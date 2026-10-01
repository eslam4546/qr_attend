import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qr_attend/firebase_options.dart';
import 'package:qr_attend/core/di/injection_container.dart' as di;
import 'package:qr_attend/core/router/app_router.dart';
import 'package:qr_attend/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Dependency Injection
  await di.init();

  runApp(const QRAttendApp());
}

class QRAttendApp extends StatelessWidget {
  const QRAttendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QR-Attend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
