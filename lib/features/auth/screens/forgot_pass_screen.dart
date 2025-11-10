import 'dart:async';
import 'package:nextpay/export.dart';
import 'package:pinput/pinput.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep =
      0; // 0: Choose Contact, 1: Enter Contact, 2: OTP, 3: New Password, 4: Success
  final contactController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedContactType = ''; // 'email' or 'sms'
  String _maskedContact = '';
  Timer? _resendTimer;
  int _resendSeconds = 0;
  bool _isResendEnabled = false;

  @override
  void dispose() {
    _resendTimer?.cancel();
    contactController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 120;
    _isResendEnabled = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _resendSeconds--);
      }
      if (_resendSeconds <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() => _isResendEnabled = true);
        }
      }
    });
  }

  void _selectContactType(String type) {
    setState(() {
      _selectedContactType = type;
      _currentStep = 1; // Go to enter contact step
    });
  }

  void _handleSendCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    // Simulate sending code
    await authProvider.sendForgotPasswordCode(
            context: context,

      contact: contactController.text);

    if (mounted) {
      // Mock masking
      if (_selectedContactType == 'email') {
        _maskedContact = _maskEmail(contactController.text);
      } else {
        _maskedContact = _maskPhone(contactController.text);
      }

      setState(() => _currentStep = 2); // Move to OTP step
      _startResendTimer();
    }
  }

  void _handleVerifyOtp() async {
    if (otpController.text.isEmpty || otpController.text.length < 4) {
      AppToast.show(
        'enter 6-digit otp code send to you through email/phone',
        context,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final verified = await authProvider.verifyForgotPasswordOtp(
      otp: otpController.text,      context: context,

    );

    if (verified && mounted) {
      setState(() => _currentStep = 3); // Move to new password step
    }
  }

  void _handleSetNewPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      AppToast.show("Password does not match!", context);
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.setNewPassword(      context: context,

      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    if (success && mounted) {
      setState(() => _currentStep = 4);
    }
  }

  void _handleBackPress() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 0);
    } else if (_currentStep == 2) {
      _resendTimer?.cancel();
      setState(() => _currentStep = 1);
    } else if (_currentStep == 3) {
      _resendTimer?.cancel();
      setState(() => _currentStep = 2);
    }
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.isNotEmpty) {
      final name = parts[0];
      if (name.length > 2) {
        return '${name.substring(0, 2)}${'*' * (name.length - 2)}@${parts[1]}';
      }
    }
    return email;
  }

  String _maskPhone(String phone) {
    if (phone.length > 4) {
      return '*' * (phone.length - 4) + phone.substring(phone.length - 4);
    }
    return phone;
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 0:
        return 'Forgot Password';
      case 1:
        return 'Enter ${_selectedContactType == 'email' ? 'Email' : 'Phone'}';
      case 2:
        return 'Verify Code';
      case 3:
        return 'New Password';
      case 4:
        return 'Success';
      default:
        return 'Forgot Password';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      appBar: MyAppBar(
        title: _getAppBarTitle(),
        onBackPressed: _handleBackPress,
        centerTitle: false,
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(key: _formKey, child: _buildCurrentStep()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildChooseContactView();
      case 1:
        return _buildEnterContactView();
      case 2:
        return _buildOtpView();
      case 3:
        return _buildNewPasswordView();
      case 4:
        return _buildSuccessView();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 0: Choose Contact Type
  Widget _buildChooseContactView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        MyText(
          text: 'Select recovery method',
          color: context.text,
          size: 28,
          weight: FontWeight.bold,
        ),
        8.height,
        MyText(
          text: 'Choose how you would like to reset your password',
          color: context.subtitle,
          size: 14,
          weight: FontWeight.w400,
        ),
        48.height,
        _buildContactOption(
          icon: Assets.emailfilled,
          title: 'Email',
          subtitle: 'Receive code via email',
          onTap: () => _selectContactType('email'),
        ),
        20.height,
        _buildContactOption(
          icon: Assets.smsfilled,
          title: 'Phone Number',
          subtitle: 'Receive code via SMS',
          onTap: () => _selectContactType('sms'),
        ),
        56.height,
      ],
    );
  }

  // Step 1: Enter Contact
  Widget _buildEnterContactView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        MyText(
          text:
              'Enter your ${_selectedContactType == 'email' ? 'email' : 'phone number'}',
          color: context.text,
          size: 28,
          weight: FontWeight.bold,
        ),
        8.height,
        MyText(
          text: 'We will send a code to verify your identity',
          color: context.subtitle,
          size: 14,
          weight: FontWeight.w400,
        ),
        40.height,
        _selectedContactType == 'email'
            ? MyTextFieldPresets.email(
                context: context,
                controller: contactController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Email required';
                  }
                  return null;
                },
              )
            : MyTextFieldPresets.phone(
                context: context,
                controller: contactController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Phone number required';
                  }
                  return null;
                },
              ),
        10.height,
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return MyButton(
              buttonText: 'Send Code',
              isLoading: authProvider.isLoading,
              onTap: _handleSendCode,
              mHoriz: 0,
              mBottom: 0,
            );
          },
        ),
        24.height,
      ],
    );
  }

  // Step 2: OTP Verification with PIN Input
  Widget _buildOtpView() {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: context.text,
      ),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.inputBorder, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: context.primary, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: context.primary, width: 2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        MyText(
          text: 'Enter verification code',
          color: context.text,
          size: 28,
          weight: FontWeight.bold,
        ),
        8.height,
        MyText(
          text: 'Code sent to $_maskedContact',
          color: context.subtitle,
          size: 14,
          weight: FontWeight.w400,
        ),
        48.height,
        Center(
          child: Pinput(
            controller: otpController,
            length: 6,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
            onCompleted: (pin) {
              // Auto verify when 4 digits entered
              _handleVerifyOtp();
            },
          ),
        ),
        56.height,
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return MyButton(
              buttonText: 'Verify',
              isLoading: authProvider.isLoading,
              onTap: _handleVerifyOtp,
              mHoriz: 0,
              mBottom: 0,
            );
          },
        ),
        20.height,
        Center(
          child: _isResendEnabled
              ? Bounce(
                  onTap: () {
                    _startResendTimer();
                  },
                  child: MyText(
                    text: 'Resend Code',
                    color: context.primary,
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                )
              : MyText(
                  text:
                      'Resend in 00:${_resendSeconds.toString().padLeft(2, '0')}',
                  color: context.subtitle,
                  size: 14,
                  weight: FontWeight.w500,
                ),
        ),
        24.height,
      ],
    );
  }

  // Step 3: New Password
  Widget _buildNewPasswordView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        MyText(
          text: 'Create new password',
          color: context.text,
          size: 28,
          weight: FontWeight.bold,
        ),
        8.height,
        MyText(
          text: 'Enter a strong password for your account',
          color: context.subtitle,
          size: 14,
          weight: FontWeight.w400,
        ),
        40.height,
        MyTextFieldPresets.password(
          context: context,
          controller: newPasswordController,
          showToggle: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Password required';
            }
            if (value!.length < 6) {
              return 'Must be at least 6 characters';
            }
            return null;
          },
        ),
        MyTextField(
          label: 'Confirm Password',
          hint: 'Re-enter password',
          controller: confirmPasswordController,
          isObSecure: true,
          showPasswordToggle: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Confirm password required';
            }
            return null;
          },
        ),
        56.height,
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return MyButton(
              buttonText: 'Reset Password',
              isLoading: authProvider.isLoading,
              onTap: _handleSetNewPassword,
              mHoriz: 0,
              mBottom: 0,
            );
          },
        ),
        24.height,
      ],
    );
  }

  // Step 4: Success
  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        64.height,
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: context.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              Assets.check,
              height: 60.0,
              color: context.icon,
            ),
          ),
        ),
        32.height,
        MyText(
          text: 'Password Reset Successfully!',
          color: context.text,
          size: 26,
          weight: FontWeight.bold,
          textAlign: TextAlign.center,
        ),
        16.height,
        MyText(
          text: 'You can now sign in with your new password',
          color: context.subtitle,
          size: 14,
          weight: FontWeight.w400,
          textAlign: TextAlign.center,
        ),
        88.height,
        MyButton(
          buttonText: 'Back to Sign In',
          onTap: () {
            Navigator.of(context).pop();
          },
          mHoriz: 0,
          mBottom: 0,
        ),
        24.height,
      ],
    );
  }

  Widget _buildContactOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: context.border, width: 2.6),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    context.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            18.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: title,
                    color: context.text,
                    size: 18.0,
                    weight: FontWeight.bold,
                  ),
                  6.height,
                  MyText(
                    text: subtitle,
                    color: context.subtitle,
                    size: 16.0,
                    weight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            SvgPicture.asset(Assets.arrowforward, height: 16.0),
          ],
        ),
      ),
    );
  }
}
