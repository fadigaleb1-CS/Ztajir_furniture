import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/data/models/address_model.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class ViewLocationScreen extends StatelessWidget {
  final AddressModel address;

  const ViewLocationScreen({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final position = LatLng(address.lat, address.lng);

    return Scaffold(
      appBar: AppBar(
        title: Text(address.title),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: position,
          initialZoom: 17.0,
          maxZoom: 20,
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
                point: position,
                width: 80.w,
                height: 80.w,
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
    );
  }
}
