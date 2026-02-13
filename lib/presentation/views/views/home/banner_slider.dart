import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ztajir_furniture/data/models/offere_model.dart';
import 'package:ztajir_furniture/presentation/views/widgets/banner_widget/banner_card.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/presentation/views/widgets/banner_widget/banner_dot.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int currentIndex = 0;

  List<OfferModel> bannerImages = [
    OfferModel(image: "images/offer3.webp"),
    OfferModel(image: "images/offer1.webp"),
    OfferModel(image: "images/offer2.webp"),
  ];

  // إنشاء Widgets جاهزة بدل map داخل السلايدر
  List<Widget> get bannerWidgets =>
      bannerImages.map((path) => BannerCard(imagePath: path.image)).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =================== السلايدر ===================
        CarouselSlider(
          items: bannerWidgets,
          options: CarouselOptions(
            height: 160.h,
            autoPlay: true,
            enlargeCenterPage: true,
            enlargeFactor: 0.16,
            autoPlayInterval: const Duration(seconds: 4),
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),

        SizedBox(height: 10.h),

        // =================== مؤشر النقاط ===================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerImages.length,
            (index) => BannerDot(currentIndex: currentIndex, index: index),
          ),
        ),
      ],
    );
  }
}
