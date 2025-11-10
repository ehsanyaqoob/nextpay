import 'package:nextpay/export.dart';

class DialogHelper {
  /// Show successful sign-in dialog
  static void showSuccessSignInDialog(BuildContext context, {VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: context.success,
                size: 48,
              ),
            ),
            const Gap(24),
            // Title
            MyText(
              text: 'Sign In Successful!',
              color: context.text,
              size: 20,
              weight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            // Message
            MyText(
              text: 'Welcome back to NextPay! You have successfully signed in to your account.',
              color: context.subtitle,
              size: 14,
              weight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            // OK Button
            MyButton(
              buttonText: 'Continue',
              onTap: () {
                Navigator.of(context).pop();
                onOkPressed?.call();
              },
              mHoriz: 0,
            ),
          ],
        ),
      ),
    );
  }

  /// Generic success dialog (for future use)
  static void showSuccessDialog(BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: context.success,
                size: 48,
              ),
            ),
            const Gap(24),
            // Title
            MyText(
              text: title,
              color: context.text,
              size: 20,
              weight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            // Message
            MyText(
              text: message,
              color: context.subtitle,
              size: 14,
              weight: FontWeight.w400,
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            // Button
            MyButton(
              buttonText: buttonText,
              onTap: () {
                Navigator.of(context).pop();
                onPressed?.call();
              },
              mHoriz: 0,
            ),
          ],
        ),
      ),
    );
  }
}