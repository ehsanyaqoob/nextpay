
import 'package:nextpay/core/utils/back_stack.dart';
import 'package:nextpay/features/screens/splash/splash_screen.dart';
import 'package:nextpay/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:nextpay/core/utils/route_config.dart';
import 'package:nextpay/export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLifecycleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<NavigationProvider>(
            builder: (context, navProvider, child) {
              return WillPopScope(
                onWillPop: () => BackPressHandler.handleBackPress(context),
                child: MaterialApp(
                  title: 'NextPay',
                  navigatorKey: navProvider.navigatorKey,
                  initialRoute: AppLinks.splashScreen,
                  onGenerateRoute: (settings) {
                    // Fallback for dynamic routes or parameters
                    return MaterialPageRoute(
                      builder: (context) {
                        final widgetBuilder = AppRoutes.routes[settings.name];
                        if (widgetBuilder != null) {
                          return widgetBuilder(context);
                        }
                        // Fallback to splash if route not found
                        return const SplashScreen();
                      },
                      settings: settings,
                    );
                  },
                  routes: AppRoutes.routes,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeProvider.themeMode,
                  debugShowCheckedModeBanner: false,
                  builder: (context, child) {
                      return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: context.isDarkMode
                      ? Brightness.light
                      : Brightness.dark,
                  systemNavigationBarColor: context.scaffoldBackground,
                  systemNavigationBarIconBrightness: context.isDarkMode
                      ? Brightness.light
                      : Brightness.dark,
                  systemNavigationBarDividerColor: Colors.transparent,
                ),
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: StateAwareWidget(
                    child: child ?? const SizedBox(),
                    onResume: () {},
                    onPause: () {},
                    onInactive: () {},
                  ),
                ),
              );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}