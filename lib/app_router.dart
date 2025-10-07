import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/edit_profile/edit_profile_module.dart';
import 'features/login/login_module.dart';
import 'features/profile/profile_module.dart';
import 'features/register/register_module.dart';
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
        builder: (context, state) => LoginModule.route(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => RegisterModule.route(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => ProfileModule.route(),
      ),
      GoRoute(
        path: '/edit_profile',
        name: 'edit_profile',
        builder: (context, state) => EditProfileModule.route(),
      ),

      // GoRoute(
      //   path: '/home',
      //   name: 'home',
      //   builder: (context, state) => HomeScreen(),
      // ),
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
