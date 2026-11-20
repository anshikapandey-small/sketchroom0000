import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../models/group.dart';
import '../../services/group_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/toast.dart';
import '../../widgets/app_button.dart';
import '../../widgets/art_thumb.dart';
import '../../widgets/empty_state.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  late final Stream<List<Group>> _groups = GroupService().watchMyGroups();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.pagePadding, 16, AppTheme.pagePadding, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Groups',
                      style: AppText.h1.copyWith(fontWeight: FontWeight.w700)),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/join'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Join / create'),
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
                    padding: EdgeInsets.symmetric(vertical: 32),
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
                    message: 'Use the + button to join with a code or create a group.',
                    action: AppButton(
                      label: 'Join or create a group',
                      variant: AppButtonVariant.soft,
                      height: 42,
                      onPressed: () => context.push('/join'),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < groups.length; i++)
                      _GroupTile(
                        group: groups[i],
                        seed: i,
                        isTeacher: groups[i].teacherId == uid,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.seed,
    required this.isTeacher,
  });

  final Group group;
  final int seed;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (group.teacherName.isNotEmpty) group.teacherName,
      group.studentsLabel,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () =>
              showToast(context, 'The group feed is built in the next step.'),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ArtThumb(seed: seed, width: 64, height: 64, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.label.copyWith(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption),
                      if (isTeacher) ...[
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: group.joinCode));
                            if (context.mounted) {
                              showToast(context, 'Code ${group.joinCode} copied');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Code: ${group.joinCode}',
                                    style: AppText.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy_rounded,
                                    size: 12, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
