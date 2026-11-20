import 'package:flutter/material.dart';
import '../models/group.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'art_thumb.dart';

/// Compact card used in the "Your groups" grid on Home.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.group, this.seed = 0, this.onTap});

  final Group group;
  final int seed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArtThumb(seed: seed, height: 72, radius: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.label
                          .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(group.studentsLabel,
                        style: AppText.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
