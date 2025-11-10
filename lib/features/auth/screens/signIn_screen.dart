import 'package:flutter/material.dart';
import 'package:nextpay/core/navigation/navigate.dart';
import 'package:nextpay/core/navigation/route_transition.dart';
import 'package:nextpay/export.dart';
import 'package:nextpay/features/auth/screens/forgot_pass_screen.dart';
import 'package:nextpay/features/screens/home/home_screen.dart';
import 'package:nextpay/widget/common/custom_checkbox_widget.dart';
import 'package:nextpay/widget/common/dialog.dart';
import 'package:nextpay/widget/common/toasts.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
void _handleSignIn() async {
  final email = emailController.text.trim();
  final password = passwordController.text;

  if (email.isEmpty) {
    AppToast.show('Email is required', context);
    return;
  }

  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email)) {
    AppToast.show('Please enter a valid email', context);
    return;
  }

  if (password.isEmpty) {
    AppToast.show('Password is required', context);
    return;
  }

  if (password.length < 6) {
    AppToast.show('Password must be at least 6 characters', context);
    return;
  }

  final authProvider = context.read<AuthProvider>();
  final success = await authProvider.signIn(
    context: context,
    email: email,
    password: password,
  );

  if (success && mounted) {
    // Show success dialog instead of toast
    DialogHelper.showSuccessSignInDialog(context, onOkPressed: () {
      Navigate.to(
        context: context,
        page: HomeScreen(),
        transition: RouteTransition.rightToLeft,
      );
    });
  } else if (authProvider.error != null) {
    AppToast.show(authProvider.error!, context);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.scaffoldBackground,
      appBar: MyAppBar(
        title: 'Sign In',
        onBackPressed: () => Navigator.of(context).pop(),
        centerTitle: false,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSizes.DEFAULT,
          child: Column(
            children: [
              Center(
                child: SvgPicture.asset(
                  Assets.nextpaylogo,
                  color: context.icon,
                  height: 100,
                  width: 80,
                ),
              ),
              const Gap(30),
              MyText(
                text: 'Welcome Back!',
                color: context.text,
                size: 28,
                weight: FontWeight.bold,
              ),
              const Gap(8),
              MyText(
                text:
                    'Please enter your email and password to proceed with sign in',
                color: context.subtitle,
                size: 14,
                weight: FontWeight.w400,
              ),
              const Gap(40),
              MyTextFieldPresets.email(
                context: context,
                controller: emailController,
              ),
              MyTextFieldPresets.password(
                context: context,
                controller: passwordController,
                showToggle: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ThemeCheckbox(
                      label: 'Remember me',
                      value: rememberMe,
                      onChanged: (value) => setState(() => rememberMe = value),
                    ),
                  ),
                  Expanded(
                    child: Bounce(
                      onTap: () {
                        Navigate.to(
                          context: context,
                          page: const ForgotPasswordScreen(),
                          transition: RouteTransition.leftToRight,
                        );
                      },
                      child: MyText(
                        text: 'Forgot Password?',
                        color: context.primary,
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              30.height, // Sign In Button
              SafeArea(
                top: false,
                child: Column(
                 mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) => MyButton(
                        buttonText: 'Sign In',
                        isLoading: authProvider.isLoading,
                        onTap: authProvider.isLoading ? null : _handleSignIn,
                        mHoriz: 0,
                        mBottom: 12,
                        mTop: 0,
                      ),
                    ),
                  ],
                ),
              ),
              6.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(
                    text: "Don't have an account? ",
                    color: context.subtitle,
                    size: 14,
                  ),
                  Bounce(
                    onTap: () => Navigator.of(context).pop(),
                    child: MyText(
                      text: 'Sign Up',
                      color: context.primary,
                      size: 14,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
