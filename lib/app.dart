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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/',
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          pageBuilder: (context, state) => _buildPageWithTransition(const SplashScreen(), state),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => _buildPageWithTransition(const LoginScreen(), state),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin',
          pageBuilder: (context, state) => _buildPageWithTransition(const AdminDashboard(), state),
        ),
        GoRoute(
          path: '/officer',
          name: 'officer',
          pageBuilder: (context, state) => _buildPageWithTransition(const OfficerDashboard(), state),
        ),
      ],
      redirect: (BuildContext ctx, GoRouterState state) {
        // IMPORTANT: use state.uri (Uri) instead of state.location
        final user = authProvider.currentUser;
        final path = state.uri.path; // '/login', '/admin', '/officer', '/'

        // If no authenticated user, send to login (unless already on login)
        if (user == null) {
          return (path == '/login') ? null : '/login';
        }

        // If authenticated and on root or login, route by role
        if (path == '/' || path == '/login') {
          if (authProvider.userType == 'admin') return '/admin';
          return '/officer';
        }

        // otherwise no redirect
        return null;
      },
    );

    return MaterialApp.router(
      title: 'Accident Record Management',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }

  CustomTransitionPage _buildPageWithTransition(Widget child, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}