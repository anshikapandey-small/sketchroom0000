import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppTheme.pagePadding, 0, AppTheme.pagePadding, 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.palette_outlined,
                    size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text('Sketchroom',
                  style: AppText.display.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Learn. Draw. Share.',
                  style: AppText.label.copyWith(color: Colors.white70)),
              const Spacer(flex: 4),
              AppButton(
                label: 'Get started',
                variant: AppButtonVariant.accent,
                onPressed: () => context.go('/signup'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text('I already have an account',
                    style: AppText.caption.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
