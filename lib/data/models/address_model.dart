import 'dart:convert';

class AddressModel {
  final String id;
  final String title;
  final String details;
  final double lat;
  final double lng;

  AddressModel({required this.id, required this.title, required this.details, required this.lat, required this.lng});

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'details': details, 'lat': lat, 'lng': lng};

  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel(
    id: map['id'],
    title: map['title'],
    details: map['details'],
    lat: map['lat'],
    lng: map['lng'],
  );

  static String encode(List<AddressModel> addresses) =>
      json.encode(addresses.map<Map<String, dynamic>>((a) => a.toMap()).toList());

  static List<AddressModel> decode(String addresses) =>
      (json.decode(addresses) as List<dynamic>).map<AddressModel>((item) => AddressModel.fromMap(item)).toList();
}