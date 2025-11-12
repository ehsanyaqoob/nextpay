import 'package:nextpay/core/navigation/navigation_provider.dart';
import 'package:nextpay/core/utils/app_routes.dart';
import 'package:nextpay/providers/verification_provider.dart';
import 'export.dart';

void main() {
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
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VerificationProvider()),

      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDarkMode = themeProvider.effectiveIsDarkMode;
          
          // Update system UI in a post-frame callback to avoid repeated calls
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDarkMode
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: isDarkMode
                    ? Brightness.dark
                    : Brightness.light,
                systemNavigationBarColor: isDarkMode
                    ? AppColors.darkBackground
                    : AppColors.background,
                systemNavigationBarIconBrightness: isDarkMode
                    ? Brightness.light
                    : Brightness.dark,
              ),
            );
          });

          return MaterialApp(
            title: 'NextPay',
            debugShowCheckedModeBanner: false,
            initialRoute: AppLinks.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            builder: (context, child) {
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: StateAwareWidget(
                  child: child ?? const SizedBox(),
                  onResume: () {},
                  onPause: () {},
                  onInactive: () {},
                  
                ),
              );
            },
          );
        },
      ),
    );
  }
}