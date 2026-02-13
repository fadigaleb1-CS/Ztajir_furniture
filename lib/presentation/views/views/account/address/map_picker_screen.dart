import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/view_model/address_service.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _selectedLocation = const LatLng(24.7136, 46.6753);
  final MapController _mapController = MapController();
  final TextEditingController _nameController = TextEditingController();
  final AddressService _addressService = AddressService();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    final location = await _addressService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _selectedLocation = location;
        _mapController.move(_selectedLocation, 15);
      });
    }
  }

  Future<void> _saveLocation() async {
    final loc = AppLocalizations.of(context)!;
    final name = await _showNameDialog(loc);

    if (name != null && name.isNotEmpty) {
      final success = await _addressService.saveAddressFromMap(
        title: name,
        details: loc.translate('map_entry'),
        location: _selectedLocation,
      );

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<String?> _showNameDialog(AppLocalizations loc) async {
    _nameController.clear();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
        ),
        title: Text(
          loc.translate('save_as'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: loc.translate('save_as_hint'),
            filled: true,
            fillColor: AppColors.whiteColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                  ),
                  child: Text(
                    loc.translate('cancel'),
                    style: TextStyle(color: AppColors.blackColor),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _nameController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                  ),
                  child: Text(
                    loc.translate('save'),
                    style: TextStyle(color: AppColors.whiteColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('specify_location')),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 17, // تكبير أعلى لتفاصيل أكثر
              minZoom: 5, // السماح بالتصغير أكثر
              maxZoom: 20, // تكبير أقصى أعلى
              onTap: (_, latlng) => setState(() => _selectedLocation = latlng),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ztajir.furniture',
                maxZoom: 20,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    child: Icon(
                      Icons.location_pin,
                      color: AppColors.redColor,
                      size: 45.w,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // زر تحديد الموقع الحالي
          Positioned(
            top: 20.h,
            right: 20.w,
            child: FloatingActionButton(
              heroTag: 'location',
              onPressed: _goToCurrentLocation,
              backgroundColor: AppColors.whiteColor,
              child: Icon(Icons.my_location, color: AppColors.primaryColor),
            ),
          ),

          // زر حفظ الموقع
          Positioned(
            bottom: 30.h,
            left: 20.w,
            right: 20.w,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: Size(double.infinity, 55.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.w),
                ),
              ),
              onPressed: _saveLocation,
              child: Text(
                loc.translate('save_location'),
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
