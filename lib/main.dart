import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/presentation/view_model/cart_service.dart';
import 'package:ztajir_furniture/presentation/view_model/language_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/payment_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/favorite_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/brand_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/category_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/product_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/connectivity_provider.dart';
import 'package:ztajir_furniture/presentation/views/views/no_internet_screen.dart';
import 'package:ztajir_furniture/presentation/views/views/main_views/splash_screen.dart';
import 'package:ztajir_furniture/presentation/views/auth_views/login_screen.dart';
import 'package:ztajir_furniture/presentation/views/auth_views/register_screen.dart';
import 'package:ztajir_furniture/presentation/view_model/order_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/branding_provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(450, 850),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: "Z-Tajir Furniture",
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartService()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => PaymentProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
        ChangeNotifierProvider(create: (context) => BrandProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => BrandingProvider()),
      ],
      child: const FurnitureApp(),
    ),
  );
}

class FurnitureApp extends StatefulWidget {
  const FurnitureApp({Key? key}) : super(key: key);

  @override
  State<FurnitureApp> createState() => _FurnitureAppState();
}

class _FurnitureAppState extends State<FurnitureApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, BrandingProvider>(
      builder: (context, languageProvider, brandingProvider, child) {
        return MaterialApp(
          title: 'تطبيق اثاث',
          theme: ThemeData(
            fontFamily: 'Cairo',
            primaryColor: AppColors.primaryColor,
            scaffoldBackgroundColor: AppColors.secondaryColor,
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              secondary: AppColors.accentColor,
              surface: AppColors.secondaryColor,
              error: AppColors.redColor,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.whiteColor,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.whiteColor,
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.whiteColor,
            ),
            progressIndicatorTheme: ProgressIndicatorThemeData(
              color: AppColors.primaryColor,
            ),
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(AppColors.primaryColor),
            ),
            radioTheme: RadioThemeData(
              fillColor: WidgetStateProperty.all(AppColors.primaryColor),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.all(AppColors.primaryColor),
              trackColor: WidgetStateProperty.all(
                AppColors.primaryColor.withOpacity(0.5),
              ),
            ),
          ),
          debugShowCheckedModeBanner: false,
          locale: languageProvider.appLocale,
          supportedLocales: const [Locale('ar', ''), Locale('en', '')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          home: const SplashScreen(),
          routes: {
            ...AppRoutes.routes,
            AppRoutes.loginScreen: (context) => const LoginScreen(),
            AppRoutes.registerScreen: (context) => const RegisterScreen(),
          },
          builder: (context, child) {
            return Consumer<ConnectivityProvider>(
              builder: (context, connectivity, unusedChild) {
                if (!connectivity.isConnected) {
                  return NoInternetScreen(onRetry: () => connectivity.retry());
                }

                // Centering the app on Wide screens (Desktop/Tablet)
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.08),
                        AppColors.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: child!,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
