import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // created by `flutterfire configure`
import 'router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SketchroomApp());
}

class SketchroomApp extends StatefulWidget {
  const SketchroomApp({super.key});

  @override
  State<SketchroomApp> createState() => _SketchroomAppState();
}

class _SketchroomAppState extends State<SketchroomApp> {
  late final AuthNotifier _auth = AuthNotifier();
  late final _router = buildRouter(_auth);

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sketchroom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
      // Keeps the app phone-sized when you test in a wide Chrome window.
      builder: (context, child) => ColoredBox(
        color: AppColors.border,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child,
          ),
        ),
      ),
    );
  }
}
