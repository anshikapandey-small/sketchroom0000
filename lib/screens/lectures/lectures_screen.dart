import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';

/// Placeholder: the real Lecture List + Video Player come in the next step.
class LecturesScreen extends StatelessWidget {
  const LecturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding, 16, AppTheme.pagePadding, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lectures',
                style: AppText.h1.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const EmptyState(
              icon: Icons.play_arrow_rounded,
              title: 'Lectures are coming next',
              message:
                  'Video lectures from your groups will appear here once we build this screen.',
            ),
          ],
        ),
      ),
    );
  }
}
