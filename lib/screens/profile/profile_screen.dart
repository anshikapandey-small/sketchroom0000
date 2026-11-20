import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/group.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/group_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Stream<UserProfile?> _profile = UserService().watchMe();
  late final Stream<List<Group>> _groups = GroupService().watchMyGroups();

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: AppText.h1),
            const SizedBox(height: 2),
            Text(label, style: AppText.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _menuRow(IconData icon, String label, VoidCallback onTap,
      {Color? color, bool chevron = true}) {
    final c = color ?? AppColors.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: AppText.label.copyWith(fontSize: 13, color: c)),
            ),
            if (chevron)
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding, 16, AppTheme.pagePadding, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile',
                style: AppText.h1.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Center(
              child: StreamBuilder<UserProfile?>(
                stream: _profile,
                builder: (context, snap) {
                  final p = snap.data;
                  final name = (p?.name.isNotEmpty ?? false)
                      ? p!.name
                      : (authUser?.displayName ?? 'Friend');
                  final initial =
                      name.isNotEmpty ? name[0].toUpperCase() : '?';
                  return Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                        child: Text(initial,
                            style: AppText.display.copyWith(color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      Text(name, style: AppText.h2),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(p?.roleLabel ?? 'Student',
                            style: AppText.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 4),
                      Text(authUser?.email ?? '', style: AppText.caption),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<Group>>(
              stream: _groups,
              builder: (context, snap) {
                final n = snap.data?.length ?? 0;
                return Row(
                  children: [
                    _stat('0', 'Drawings'),
                    const SizedBox(width: 10),
                    _stat('0', 'Lectures'),
                    const SizedBox(width: 10),
                    _stat('$n', 'Groups'),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _menuRow(Icons.image_outlined, 'My drawings',
                      () => showToast(context, 'My drawings arrive soon.')),
                  const Divider(height: 1, color: AppColors.border),
                  _menuRow(Icons.groups_outlined, 'My groups',
                      () => context.go('/groups')),
                  const Divider(height: 1, color: AppColors.border),
                  _menuRow(Icons.notifications_none_rounded, 'Notifications',
                      () => showToast(context, 'Notifications arrive in Version 2.')),
                  const Divider(height: 1, color: AppColors.border),
                  _menuRow(Icons.help_outline_rounded, 'Help and support',
                      () => showToast(context, 'Help is coming soon.')),
                  const Divider(height: 1, color: AppColors.border),
                  _menuRow(Icons.logout_rounded, 'Log out',
                      () => AuthService().signOut(),
                      color: AppColors.danger, chevron: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
