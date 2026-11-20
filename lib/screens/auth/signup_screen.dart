import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_segmented.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  int _roleIndex = 0; // 0 = Student, 1 = Teacher
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signUp(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        role: _roleIndex == 0 ? 'student' : 'teacher',
      );
      // The router sends the user to /home automatically.
    } catch (e) {
      _toast(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppTheme.pagePadding, 12, AppTheme.pagePadding, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBackButton(onPressed: () => context.go('/splash')),
                      const SizedBox(height: 24),
                      Text('Create account', style: AppText.display),
                      const SizedBox(height: 8),
                      Text('Join as a student or a teacher.',
                          style: AppText.caption.copyWith(fontSize: 13)),
                      const SizedBox(height: 20),
                      AppSegmented(
                        options: const ['Student', 'Teacher'],
                        selectedIndex: _roleIndex,
                        onChanged: (i) => setState(() => _roleIndex = i),
                      ),
                      const SizedBox(height: 20),
                      AppInput(
                        label: 'Full name',
                        hint: 'Your name',
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: (v) => Validators.required(v, 'Name'),
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        label: 'Email',
                        hint: 'you@example.com',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        label: 'Password',
                        hint: 'At least 8 characters',
                        controller: _password,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: Validators.password,
                        onSubmitted: (_) => _signUp(),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Create account',
                        loading: _loading,
                        onPressed: _signUp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: AppText.caption),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text('Log in',
                        style: AppText.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
