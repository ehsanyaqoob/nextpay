import 'package:nextpay/core/navigation/navigate.dart';
import 'package:nextpay/core/navigation/route_transition.dart';
import 'package:nextpay/core/utils/app_routes.dart';
import 'package:nextpay/export.dart';
import 'package:nextpay/features/auth/screens/signIn_screen.dart';
import 'package:nextpay/features/auth/screens/sign_up_screen.dart';

class GetStartScreen extends StatefulWidget {
  const GetStartScreen({super.key});

  @override
  State<GetStartScreen> createState() => _GetStartScreenState();
}

class _GetStartScreenState extends State<GetStartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: AppSizes.DEFAULT,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Assets.nextpaylogo,
                height: 200,
                color: ThemeColors.buttonBackground(context),
              ),
              10.height,
              MyText(
                textAlign: TextAlign.center,
                text: 'Lets Get Started!',
                color: context.text,
                size: 30.0,
                weight: FontWeight.bold,
              ),
              10.height,
              MyText(
                textAlign: TextAlign.center,
                text:
                    'With NextPay sending and receiving money is easier than ever before',
                color: context.subtitle,
                size: 14.0,
                weight: FontWeight.w400,
              ),
              40.height,
              // Sign In Button - Primary Style
              MyButton(
                buttonText: 'Sign In',
                onTap: () {
                  Navigate.to(
                    context: context,
                    page: const SigninScreen(),
                    transition: RouteTransition.rightToLeft,
                  );
                },
                backgroundColor: context.buttonBackground,
              ),
              16.height,
              MyButton(
                buttonText: 'Sign Up',
                onTap: () {
                  Navigate.to(
                    context: context,
                    page: const SignUpScreen(),
                    transition: RouteTransition.leftToRight,
                  );
                },
                backgroundColor: Colors.transparent,
                outlineColor: context.buttonBackground,
                fontColor:
                    context.buttonBackground, 
              ),
            ],
          ),
        ),
      ),
    );
  }
}
