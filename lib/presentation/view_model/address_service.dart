import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ztajir_furniture/data/models/address_model.dart';

class AddressService {
  static const String _storageKey = 'user_addresses';

  /// تحميل العناوين المحفوظة
  Future<List<AddressModel>> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      return AddressModel.decode(data);
    }
    return [];
  }

  /// حفظ قائمة العناوين
  Future<void> saveAddresses(List<AddressModel> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, AddressModel.encode(addresses));
  }

  /// إضافة عنوان جديد
  Future<List<AddressModel>> addAddress(AddressModel address) async {
    final addresses = await loadAddresses();
    addresses.add(address);
    await saveAddresses(addresses);
    return addresses;
  }

  /// حذف عنوان
  Future<List<AddressModel>> deleteAddress(int index) async {
    final addresses = await loadAddresses();
    if (index >= 0 && index < addresses.length) {
      addresses.removeAt(index);
      await saveAddresses(addresses);
    }
    return addresses;
  }

  /// إنشاء عنوان جديد
  AddressModel createAddress({
    required String title,
    required String details,
    double lat = 0.0,
    double lng = 0.0,
  }) {
    return AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      details: details,
      lat: lat,
      lng: lng,
    );
  }

  /// الحصول على الموقع الحالي
  Future<LatLng?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  /// حفظ عنوان من الخريطة
  Future<bool> saveAddressFromMap({
    required String title,
    required String details,
    required LatLng location,
  }) async {
    try {
      final address = createAddress(
        title: title,
        details: details,
        lat: location.latitude,
        lng: location.longitude,
      );
      await addAddress(address);
      return true;
    } catch (e) {
      return false;
    }
  }
}
