import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/branding_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. إعداد الأنيميشن
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // زيادة مدة الحركة
    );

    // تأثير التلاشي (Fade In)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );

    // تأثير التكبير المرن (Elastic Pop) - حركة احترافية
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        // يبدأ متأخراً قليلاً (0.3) وينتهي بمرونة عالية
        curve: const Interval(0.3, 0.9, curve: Curves.elasticOut),
      ),
    );

    // بدء الأنيميشن
    _controller.forward();

    // 2. تحميل البيانات والانتقال (بعد انتهاء بناء الواجهة)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initApp();
    });
  }

  Future<void> _initApp() async {
    // انتظار زمني أقصر (3 ثواني كافية للأنيميشن)
    final minWait = Future.delayed(const Duration(seconds: 3));

    // تحميل البيانات مع timeout لتجنب الانتظار الطويل عند عدم وجود إنترنت
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final brandingProvider = Provider.of<BrandingProvider>(
        context,
        listen: false,
      );

      // تحميل الألوان والبيانات في الخلفية مع timeout 5 ثواني
      await Future.wait([
        brandingProvider.fetchBranding().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('⚠️ Branding timeout - using defaults');
          },
        ),
        authProvider.checkLoginStatus().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('⚠️ Auth check timeout');
          },
        ),
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ Init timeout - proceeding anyway');
          return [];
        },
      );
    } catch (e) {
      debugPrint('Error initializing app: $e');
      // استمر حتى لو فشلت الطلبات
    }

    // التأكد من انتهاء الوقت الأدنى للأنيميشن
    await minWait;

    if (!mounted) return;

    // الانتقال للشاشة الرئيسية دائماً (تدعم الضيف والمسجل)
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تهيئة الحجم إذا لم يتم تهيئته بعد
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor, // خلفية بيضاء نظيفة
      body: Stack(
        children: [
          // ================== شعار المتجر من الـ API (في الوسط) ==================
          Align(
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: 200.w,
                height: 200.w,
                child: Consumer<BrandingProvider>(
                  builder: (context, brandingProvider, _) {
                    final logoUrl = brandingProvider.logos.logo;
                    if (logoUrl != null && logoUrl.isNotEmpty) {
                      return Image.network(
                        logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.store_rounded,
                          size: 80.w,
                          color: AppColors.primaryColor,
                        ),
                      );
                    }
                    // أثناء التحميل أو في حالة عدم وجود شعار
                    return Icon(
                      Icons.store_rounded,
                      size: 80.w,
                      color: AppColors.primaryColor,
                    );
                  },
                ),
              ),
            ),
          ),

          // ================== شعار المطور (في الأسفل) ==================
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.h), // مسافة من الأسفل
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.translate('developed_by') ??
                          "Developed by",
                      style: TextStyle(
                        color: AppColors.darkGreyColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    SizedBox(
                      width: 120.w, // حجم شعار ز تاجر
                      height: 50.h,
                      child: Image.asset(
                        'images/logo/3.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
