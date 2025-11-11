import 'package:nextpay/export.dart';
import 'package:nextpay/widget/common/dot-loader.dart';

class DialogHelper {
  /// Show successful sign-in dialog matching the design in image
  static void showSuccessSignInDialog(
    BuildContext context, {
    VoidCallback? onOkPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: context.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(
            minHeight: 460, // Perfect height for content
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            children: [
              // Success icon with loader - Centered
              Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Success check icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        Assets.check, 
                        
                        color: context.icon, 
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: NextPayLoader(
                      size: 100.0,
                      dotSize: 6.0,
                      color: context.primary,
                    ),
                  ),
                ],
              ),
              const Gap(32),
             
              MyText(
                text: 'Sign in Successful!',
                color: context.primary,
                size: 18,
                weight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              // Loading text
              MyText(
                text: 'Please wait...',
                color: context.subtitle,
                size: 16,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              // Redirect message
              MyText(
                text: 'You will be directed to the homepage.',
                color: context.subtitle,
                size: 14,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              10.height,
              NextPayLoader(
                      size: 40.0,
                      dotSize: 6.0,
                      color: context.primary,
                    ),
            ],
          ),
        ),
      ),
    );

    // Auto navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      onOkPressed?.call();
    });
  }

  /// Generic success dialog with similar design (for future use)
  static void showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    String successMessage = 'Successful!',
    String loadingText = 'Please wait...',
    String redirectText = 'You will be redirected shortly.',
    int autoCloseDuration = 3,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: context.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(
            minHeight: 460, // Perfect height for content
            maxWidth: 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            children: [
              // Success icon with loader
              Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Success check icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        Assets.check, 
                        color: context.icon, // Ensure icon is visible on primary background
                      ),
                    ),
                  ),
                  // Loader around the success icon
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: NextPayLoader(
                      size: 100.0,
                      dotSize: 6.0,
                      color: context.primary,
                    ),
                  ),
                ],
              ),
              const Gap(32),
             
              MyText(
                text: successMessage,
                color: context.primary,
                size: 18,
                weight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              // Loading text
              MyText(
                text: loadingText,
                color: context.subtitle,
                size: 16,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              // Redirect message
              MyText(
                text: redirectText,
                color: context.subtitle,
                size: 14,
                weight: FontWeight.w400,
                textAlign: TextAlign.center,
              ), 10.height,
              NextPayLoader(
                      size: 40.0,
                      dotSize: 6.0,
                      color: context.primary,
                    ),
            ],
          ),
        ),
      ),
    );

    // Auto close after specified duration
    Future.delayed(Duration(seconds: autoCloseDuration), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      onPressed?.call();
    });
  }
}