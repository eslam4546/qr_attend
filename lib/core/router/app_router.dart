import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:qr_attend/features/auth/presentation/pages/login_page.dart';
import 'package:qr_attend/features/auth/presentation/pages/register_page.dart';
import 'package:qr_attend/features/courses/presentation/pages/professor_home_page.dart';
import 'package:qr_attend/features/courses/presentation/pages/student_home_page.dart';
import 'package:qr_attend/features/courses/presentation/pages/course_detail_page.dart';
import 'package:qr_attend/features/sessions/presentation/pages/live_session_page.dart';
import 'package:qr_attend/features/attendance/presentation/pages/scanner_page.dart';
import 'package:qr_attend/features/attendance/presentation/pages/attendance_history_page.dart';

/// Route path constants to avoid magic strings.
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String profHome = '/prof/home';
  static const String profCourse = '/prof/course/:courseId';
  static const String profSession = '/prof/session/:sessionId';
  static const String studentHome = '/student/home';
  static const String studentScan = '/student/scan';
  static const String studentHistory = '/student/history/:courseId';
}

class AppRouter {
  // These will be set by AuthCubit via the refresh listenable.
  // null  = still checking auth state (splash)
  // false = unauthenticated
  // true  = authenticated
  static ValueNotifier<bool?> isAuthenticated = ValueNotifier<bool?>(null);

  // 'professor' or 'student' — set after login/signup
  static ValueNotifier<String?> userRole = ValueNotifier<String?>(null);

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    refreshListenable: isAuthenticated,
    redirect: _redirect,
    routes: [
      // ── Auth ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ── Professor ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.profHome,
        name: 'profHome',
        builder: (context, state) => const ProfessorHomePage(),
      ),
      GoRoute(
        path: AppRoutes.profCourse,
        name: 'profCourse',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CourseDetailPage(courseId: courseId);
        },
      ),
      GoRoute(
        path: AppRoutes.profSession,
        name: 'profSession',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return LiveSessionPage(sessionId: sessionId);
        },
      ),

      // ── Student ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.studentHome,
        name: 'studentHome',
        builder: (context, state) => const StudentHomePage(),
      ),
      GoRoute(
        path: AppRoutes.studentScan,
        name: 'studentScan',
        builder: (context, state) => const ScannerPage(),
      ),
      GoRoute(
        path: AppRoutes.studentHistory,
        name: 'studentHistory',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return AttendanceHistoryPage(courseId: courseId);
        },
      ),
    ],
  );

  /// Global redirect logic:
  /// 1. If auth state is unknown (null), stay on login (splash in future).
  /// 2. If unauthenticated, redirect to login.
  /// 3. If authenticated and on an auth page, redirect to role-based home.
  static String? _redirect(BuildContext context, GoRouterState state) {
    final loggedIn = isAuthenticated.value;
    final role = userRole.value;
    final currentPath = state.matchedLocation;

    final isAuthRoute =
        currentPath == AppRoutes.login || currentPath == AppRoutes.register;

    // Still checking auth — don't redirect
    if (loggedIn == null) return null;

    // Not authenticated — force to login
    if (loggedIn == false) {
      return isAuthRoute ? null : AppRoutes.login;
    }

    // Authenticated but on auth page — go to role home
    if (loggedIn == true && isAuthRoute) {
      if (role == 'professor') return AppRoutes.profHome;
      if (role == 'student') return AppRoutes.studentHome;
      // Fallback if role is somehow not set
      return AppRoutes.login;
    }

    return null; // No redirect needed
  }
}
