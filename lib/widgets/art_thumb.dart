import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Colourful shapes used as a thumbnail placeholder (like the Figma cards).
class ArtThumb extends StatelessWidget {
  const ArtThumb({
    super.key,
    this.seed = 0,
    required this.height,
    this.width,
    this.radius = 10,
  });

  final int seed;
  final double height;
  final double? width;
  final double radius;

  static const _bgs = [
    Color(0xFFE3F7EF),
    AppColors.primarySoft,
    AppColors.accentSoft,
    Color(0xFFFFF4D6),
  ];
  static const _big = [
    AppColors.success,
    AppColors.primary,
    AppColors.accent,
    AppColors.warn,
  ];
  static const _mid = [
    AppColors.primary,
    AppColors.accent,
    AppColors.primary,
    AppColors.accent,
  ];
  static const _pill = [
    AppColors.accent,
    AppColors.success,
    AppColors.success,
    AppColors.primary,
  ];

  Widget _circle(double d, Color c) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  @override
  Widget build(BuildContext context) {
    final i = seed.abs() % _bgs.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth.isFinite ? c.maxWidth : height * 1.5;
          final h = height;
          return Stack(children: [
            Positioned.fill(child: ColoredBox(color: _bgs[i])),
            Positioned(left: -w * 0.1, bottom: -h * 0.35, child: _circle(h, _big[i])),
            Positioned(right: w * 0.12, top: h * 0.12, child: _circle(h * 0.5, _mid[i])),
            Positioned(
              left: w * 0.35,
              bottom: h * 0.2,
              child: Container(
                width: w * 0.5,
                height: h * 0.16,
                decoration: BoxDecoration(
                  color: _pill[i],
                  borderRadius: BorderRadius.circular(h),
                ),
              ),
            ),
          ]);
        }),
      ),
    );
  }
}
