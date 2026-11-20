import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/group.dart';
import '../../models/user_profile.dart';
import '../../services/group_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/toast.dart';
import '../../widgets/app_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/group_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<UserProfile?> _profile = UserService().watchMe();
  late final Stream<List<Group>> _groups = GroupService().watchMyGroups();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
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
            // Greeting + bell
            StreamBuilder<UserProfile?>(
              stream: _profile,
              builder: (context, snap) {
                final name = (snap.data?.name.isNotEmpty ?? false)
                    ? snap.data!.name
                    : (authUser?.displayName ?? 'there');
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_greeting(),
                              style: AppText.caption.copyWith(fontSize: 11)),
                          Text(name, style: AppText.h2),
                        ],
                      ),
                    ),
                    Material(
                      color: AppColors.card,
                      shape: const CircleBorder(
                          side: BorderSide(color: AppColors.border)),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => showToast(
                            context, 'Notifications arrive in Version 2.'),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(Icons.notifications_none_rounded,
                              size: 20, color: AppColors.ink),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Search (visual only for now)
            GestureDetector(
              onTap: () => showToast(context, 'Search is coming soon.'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        size: 18, color: AppColors.muted),
                    const SizedBox(width: 10),
                    Text('Search lectures, groups, drawings',
                        style: AppText.caption.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Your groups
            Row(
              children: [
                Expanded(
                  child: Text('Your groups',
                      style: AppText.label.copyWith(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                GestureDetector(
                  onTap: () => context.go('/groups'),
                  child: Text('See all',
                      style: AppText.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Group>>(
              stream: _groups,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Text('Could not load groups.',
                      style: AppText.caption.copyWith(color: AppColors.danger));
                }
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2.5)),
                  );
                }
                final groups = snap.data!;
                if (groups.isEmpty) {
                  return EmptyState(
                    icon: Icons.groups_outlined,
                    title: 'No groups yet',
                    message:
                        'Join a class with the code from your teacher, or create one if you are a teacher.',
                    action: AppButton(
                      label: 'Join or create a group',
                      variant: AppButtonVariant.soft,
                      height: 42,
                      onPressed: () => context.push('/join'),
                    ),
                  );
                }
                return LayoutBuilder(builder: (context, c) {
                  final w = (c.maxWidth - 12) / 2;
                  final shown = groups.take(4).toList();
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (var i = 0; i < shown.length; i++)
                        SizedBox(
                          width: w,
                          child: GroupCard(
                            group: shown[i],
                            seed: i,
                            onTap: () => showToast(context,
                                'The group feed is built in the next step.'),
                          ),
                        ),
                    ],
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
