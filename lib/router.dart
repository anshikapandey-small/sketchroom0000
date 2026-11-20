import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/groups/join_group_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/lectures/lectures_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/shell/shell_scaffold.dart';

/// Tells go_router to re-check redirects whenever login state changes.
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

GoRouter buildRouter(AuthNotifier auth) {
  const publicRoutes = ['/splash', '/login', '/signup'];

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final isPublic = publicRoutes.contains(state.matchedLocation);
      if (!loggedIn && !isPublic) return '/splash';
      if (loggedIn && isPublic) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/join', builder: (_, __) => const JoinGroupScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/groups', builder: (_, __) => const GroupsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/lectures', builder: (_, __) => const LecturesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
}
