import 'package:flutter/material.dart';
import 'package:nextpay/core/navigation/navigate.dart';
import 'package:nextpay/core/navigation/route_transition.dart';
import 'package:nextpay/export.dart';
import 'package:nextpay/features/auth/screens/details_form_screen.dart';
import 'package:nextpay/widget/common/custom_checkbox_widget.dart';
import 'package:nextpay/widget/common/toasts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool agreeTerms = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
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

    if (!agreeTerms) {
      AppToast.show('You must agree to the terms', context);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      context: context,
      email: email,
      password: password,
    );

    if (success && mounted) {
      Navigate.replace(
        context: context,
        page: const DetailsFormScreen(),
        transition: RouteTransition.rightToLeft,
      );
    } else if (authProvider.error != null) {
      AppToast.show(authProvider.error!, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      appBar: MyAppBar(
        title: 'Sign Up',
        onBackPressed: () => Navigator.of(context).pop(),
        centerTitle: false,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: AppSizes.DEFAULT,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SvgPicture.asset(
                    Assets.nextpaylogo,
                    color: context.icon,
                    height: 100,
                    width: 80,
                  ),
                ),
                MyText(
                  text: 'Create Account!',
                  color: context.text,
                  size: 28,
                  weight: FontWeight.bold,
                ),
                const Gap(4),
                MyText(
                  text: 'Please enter your email and password to create your account',
                  color: context.subtitle,
                  size: 14,
                  weight: FontWeight.w400,
                ),
                const Gap(10),
                MyTextFieldPresets.email(
                  context: context,
                  controller: emailController,
                ),
                MyTextFieldPresets.password(
                  context: context,
                  controller: passwordController,
                  showToggle: true,
                ),
                ThemeCheckbox(
                  label: 'I agree to Terms & Conditions',
                  value: agreeTerms,
                  onChanged: (value) => setState(() => agreeTerms = value),
                ),
                const Gap(10),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) => MyButton(
                    buttonText: 'Sign Up',
                    isLoading: authProvider.isLoading,
                    onTap: authProvider.isLoading ? null : _handleSignUp,
                    mHoriz: 0,
                    mBottom: 0,
                    mTop: 0,
                  ),
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                      text: "Already have an account? ",
                      color: context.subtitle,
                      size: 14,
                    ),
                    Bounce(
                      onTap: () => Navigator.of(context).pop(),
                      child: MyText(
                        text: 'Sign In',
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
      ),
    );
  }
}