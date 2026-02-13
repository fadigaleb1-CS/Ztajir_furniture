import 'package:ztajir_furniture/data/models/brand_model.dart';
import 'package:ztajir_furniture/data/models/category_model.dart';
import 'package:ztajir_furniture/data/models/user_model.dart';
import '../models/product_model.dart';

// بيانات وهمية جاهزة للاستخدام في الواجهة
class MockData {
  // المستخدم الحالي (نستخدمه لعرض الاسم والإيميل في AppBar عند عدم تسجيل الدخول)
  static UserModel currentUser = UserModel(
    id: 1,
    firstName: "فادي",
    lastName: "الجساسي",
    email: "fadi@example.com",
    avatarUrl: "images/user.jpg", // هذه الصورة سنحتفظ بها
  );

  // تم إفراغ القوائم للاعتماد على الـ API
  static List<CategoryModel> categories = [];
  static List<BrandModel> brands = [];
  static List<ProductModel> allProducts = [];

  // دوال مساعدة (ستعيد قوائم فارغة الآن)
  static List<ProductModel> productsByCategory(int catId) => [];
  static List<ProductModel> productsByBrand(int brandId) => [];
  static List<ProductModel> get favoriteProducts => [];
}
