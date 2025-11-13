import 'package:nextpay/core/navigation/navigate.dart';
import 'package:nextpay/core/navigation/route_transition.dart';
import 'package:nextpay/export.dart';
import 'package:nextpay/features/screens/home/home_screen.dart';
import 'package:pinput/pinput.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  int _currentStep = 1; // 1: Set PIN, 2: Confirm PIN

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _proceedToConfirm() {
    if (_pinController.text.length != 4) {
      AppToast.show('Please enter 4-digit PIN', context, type: ToastType.error);
      return;
    }
    setState(() => _currentStep = 2);
  }

  void _completePinSetup() {
    if (_confirmPinController.text.length != 4) {
      AppToast.show('Please confirm your PIN', context, type: ToastType.error);
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      AppToast.show('PINs do not match', context, type: ToastType.error);
      _confirmPinController.clear();
      return;
    }

    _savePin();
  }

  Future<void> _savePin() async {
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        AppToast.show('PIN secured successfully!', context, type: ToastType.success);
        
        Navigate.to(
          context: context,
          page: const HomeScreen(),
          transition: RouteTransition.rightToLeft,
        );
      }
    } catch (e) {
      AppToast.show('Failed to set PIN', context, type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: AppSizes.DEFAULT,
      child: Row(
        children: [
          _buildStepCircle(1, 'Set PIN'),
          8.width,
          Container(width: 40, height: 2, color: context.border),
          8.width,
          _buildStepCircle(2, 'Confirm'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isActive = step == _currentStep;
    bool isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? context.primary : (isActive ? context.primary : context.card),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? context.primary : context.border,
              width: 2,
            ),
          ),
          child: isCompleted 
              ? Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        4.height,
        MyText(
          text: label,
          color: isActive ? context.primary : context.subtitle,
          size: 10,
          weight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildPinInput() {
    final pinTheme = PinTheme(
      width: 70,
      height: 70,
      textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: context.text),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.inputBorder, width: 1.5),
      ),
    );

    return Column(
      children: [
        40.height,
        MyText(
          text: _currentStep == 1 ? 'Create PIN' : 'Confirm PIN',
          color: context.text,
          size: 24,
          weight: FontWeight.bold,
        ),
        12.height,
        MyText(
          text: _currentStep == 1 
              ? 'Enter a 4-digit PIN to secure your account'
              : 'Re-enter your PIN to confirm',
          color: context.subtitle,
          size: 14,
          textAlign: TextAlign.center,
        ),
        48.height,
        Pinput(
          controller: _currentStep == 1 ? _pinController : _confirmPinController,
          length: 4,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          defaultPinTheme: pinTheme,
          focusedPinTheme: pinTheme.copyDecorationWith(
            border: Border.all(color: context.primary, width: 2),
          ),
          obscureText: true,
          obscuringCharacter: '•',
          onCompleted: (pin) {
            if (_currentStep == 1) {
              _proceedToConfirm();
            } else {
              _completePinSetup();
            }
          },
        ),
        56.height,
        MyButton(
          buttonText: _currentStep == 1 ? 'Continue' : 'Set PIN',
          isLoading: _isLoading,
          onTap: _currentStep == 1 ? _proceedToConfirm : _completePinSetup,
          mHoriz: 0,
          isActive: _currentStep == 1 
              ? _pinController.text.length != 4
              : _confirmPinController.text.length != 4,
        ),
        if (_currentStep == 2) ...[
          16.height,
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _currentStep = 1),
              child: MyText(
                text: 'Back to change PIN',
                color: context.primary,
                size: 14,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      appBar: MyAppBar(
        title: 'Security PIN',
        onBackPressed: () => Navigator.of(context).pop(),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
      padding: AppSizes.DEFAULT,
          child: Column(
            children: [
              _buildStepIndicator(),
              _buildPinInput(),
            ],
          ),
        ),
      ),
    );
  }
}