import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/tv/tv_focusable.dart';
import '../providers/auth_provider.dart';
import '../shared/widgets/app_logo.dart';
import '../shared/widgets/kids_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your account email')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).resetPassword(email);
    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _emailSent
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F8F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_read_rounded,
                            color: AppColors.success,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('Reset Link Sent!', style: AppTypography.displayMedium),
                        const SizedBox(height: 10),
                        Text(
                          'We sent password recovery instructions to:\n${_emailController.text.trim()}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        TvFocusable(
                          onPressed: () => context.pushReplacement('/user-login'),
                          child: KidsButton(
                            label: 'Back to Sign In',
                            icon: Icons.arrow_back_rounded,
                            width: double.infinity,
                            onPressed: () => context.pushReplacement('/user-login'),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: 54),
                        const SizedBox(height: 16),
                        Text('Forgot Password', style: AppTypography.displayMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your email address and we\'ll send you a password reset link.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),

                        if (authState.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withAlpha(60)),
                            ),
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Your Account Email',
                            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 24),

                        TvFocusable(
                          onPressed: _handleReset,
                          child: KidsButton(
                            label: 'Send Recovery Email',
                            icon: Icons.send_rounded,
                            width: double.infinity,
                            height: 50,
                            isLoading: authState.isLoading,
                            onPressed: _handleReset,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TvFocusable(
                          onPressed: () => context.pop(),
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('Back to Sign In'),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
