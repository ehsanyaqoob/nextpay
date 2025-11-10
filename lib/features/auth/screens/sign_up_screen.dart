import 'package:nextpay/core/navigation/navigate.dart';
import 'package:nextpay/core/navigation/route_transition.dart';
import 'package:nextpay/export.dart';
import 'package:nextpay/features/screens/home/home_screen.dart';
import 'package:nextpay/widget/common/custom_checkbox_widget.dart';
import 'package:nextpay/widget/common/dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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

    if (email.isEmpty) return AppToast.show('Email is required', context);
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email)) {
      return AppToast.show('Please enter a valid email', context);
    }

    if (password.isEmpty) return AppToast.show('Password is required', context);
    if (password.length < 6)
      return AppToast.show('Password must be at least 6 characters', context);

    if (!agreeTerms)
      return AppToast.show('You must agree to the terms', context);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      context: context,
      email: email,
      password: password,
    );

    if (success && mounted) {
      // Navigate.to(
      //     context: context,
      //     page: HomeScreen(),
      //     transition: RouteTransition.rightToLeft,
      //   );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.scaffoldBackground,
      appBar: MyAppBar(
        title: 'Sign Up',
        onBackPressed: () => Navigator.of(context).pop(),
        centerTitle: false,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              padding: AppSizes.DEFAULT,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    text: 'Create Account',
                    color: context.text,
                    size: 28,
                    weight: FontWeight.bold,
                  ),
                  const Gap(8),
                  MyText(
                    text: 'Sign up to get started with NextPay',
                    color: context.subtitle,
                    size: 14,
                    weight: FontWeight.w400,
                    textAlign: TextAlign.center,
                  ),
                  10.height,
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
                  30.height,
                  SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) => MyButton(
                            buttonText: 'Sign Up',
                            isLoading: authProvider.isLoading,
                            onTap: authProvider.isLoading
                                ? null
                                : _handleSignUp,
                            mHoriz: 0,
                            mBottom: 12,
                            mTop: 0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyText(
                              text: 'Already have an account? ',
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
                        const Gap(12),
                      ],
                    ),
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
