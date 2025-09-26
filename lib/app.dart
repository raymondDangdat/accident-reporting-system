import 'package:ars/core/features/auth/presentations/screens/login_screen.dart';
import 'package:ars/core/features/auth/presentations/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/features/accidents/screens/officer_dashboard.dart';
import 'core/features/admin/screens/admin_dashboard.dart';
import 'core/features/auth/providers/auth_provider.dart';

class AccidentRecordApp extends StatelessWidget {
  const AccidentRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    final router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/',
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(const SplashScreen(), state),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(const LoginScreen(), state),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(const AdminDashboard(), state),
        ),
        GoRoute(
          path: '/officer',
          name: 'officer',
          pageBuilder: (context, state) =>
              _buildPageWithTransition(const OfficerDashboard(), state),
        ),
      ],
      redirect: (BuildContext ctx, GoRouterState state) {
        final user = authProvider.currentUser;
        final path = state.uri.path; // '/', '/login', '/admin', '/officer'

        // ⚡ Let SplashScreen handle its own navigation
        if (path == '/') return null;

        // If no authenticated user → force login
        if (user == null) {
          return (path == '/login') ? null : '/login';
        }

        // If authenticated and on login → send them to dashboard
        if (path == '/login') {
          if (authProvider.userType == 'admin') return '/admin';
          return '/officer';
        }

        // Otherwise, allow navigation
        return null;
      },
    );

    return MaterialApp.router(
      title: 'Accident Record Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      routerConfig: router,
    );
  }

  CustomTransitionPage _buildPageWithTransition(
      Widget child, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}