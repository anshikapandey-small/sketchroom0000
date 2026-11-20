import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../services/group_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/toast.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_button.dart';
import '../../widgets/code_input.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _groups = GroupService();
  final _users = UserService();
  String _code = '';
  bool _joining = false;
  bool _creating = false;

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _join() async {
    setState(() => _joining = true);
    try {
      await _groups.joinGroup(_code);
      if (!mounted) return;
      showToast(context, 'You joined the group!');
      context.go('/groups');
    } catch (e) {
      if (mounted) showToast(context, GroupService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _createGroup() async {
    final profile = await _users.getMe();
    if (!mounted) return;
    if (profile?.isTeacher != true) {
      showToast(context,
          'Only teachers can create groups. Sign up with a Teacher account to do this.');
      return;
    }

    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Create group', style: AppText.h2),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g. Sketching Basics - Batch A'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, nameCtrl.text),
              child: const Text('Create')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;

    setState(() => _creating = true);
    try {
      final code = await _groups.createGroup(name.trim());
      if (!mounted) return;
      await _showCodeDialog(name.trim(), code);
      if (mounted) context.go('/groups');
    } catch (e) {
      if (mounted) showToast(context, GroupService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _showCodeDialog(String groupName, String code) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Group created', style: AppText.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share this code with your students so they can join "$groupName".',
              style: AppText.caption.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Center(
              child: SelectableText(
                code,
                style: AppText.display
                    .copyWith(letterSpacing: 6, color: AppColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (ctx.mounted) showToast(ctx, 'Code copied');
            },
            child: const Text('Copy code'),
          ),
          FilledButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppTheme.pagePadding, 12, AppTheme.pagePadding, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackButton(onPressed: _close),
              const SizedBox(height: 24),
              Text('Join a group', style: AppText.h1.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-character code your teacher shared with you.',
                style: AppText.caption.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 24),
              CodeInput(onChanged: (v) => setState(() => _code = v)),
              const SizedBox(height: 20),
              AppButton(
                label: 'Join group',
                loading: _joining,
                onPressed: _code.length == 6 && !_creating ? _join : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: AppText.caption),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: AppColors.primarySoft, shape: BoxShape.circle),
                      child: const Icon(Icons.groups_outlined,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(height: 12),
                    Text('Create a new group',
                        style: AppText.label
                            .copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'For teachers: start a class, upload lectures and invite students with a code.',
                      style: AppText.caption.copyWith(fontSize: 12.5),
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label: 'Create group',
                      variant: AppButtonVariant.outline,
                      height: 42,
                      loading: _creating,
                      onPressed: _joining ? null : _createGroup,
                    ),
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
