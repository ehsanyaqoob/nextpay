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
          // 1. Change mainAxisAlignment to space between/end
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 2. Wrap all content above the buttons in an Expanded widget
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // To keep the logo/text centered vertically
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
                    text: 'With NextPay sending and receiving money is easier than ever before',
                    color: context.subtitle,
                    size: 14.0,
                    weight: FontWeight.w400,
                  ),
                  40.height,
                ],
              ),
            ),
            
            // This Row now stays at the bottom
            Row(
              children: [
                Expanded(
                  child: MyButton(
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
                ),
                Gap(10),
                Expanded(
                  child: MyButton(
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
                    fontColor: context.buttonBackground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}}