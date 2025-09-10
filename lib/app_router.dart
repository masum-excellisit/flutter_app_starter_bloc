import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/splash/screens/splash_screen.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Home Page - Coming Soon'),
          ),
        ),
      ),
      // GoRoute(
      //   path: '/profile',
      //   name: 'profile',
      //   builder: (context, state) => const ProfilePage(),
      // ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found!'),
      ),
    ),
  );
}
