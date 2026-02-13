import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late Orientation orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;

    // Cap scaling for Desktop/Web to avoid massive UI
    if (screenWidth > 500) {
      screenWidth = 450;
    }
  }
}

/// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designer use
  return (inputHeight / 812.0) * screenHeight;
}

/// Get the proportionate width as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  return (inputWidth / 375.0) * screenWidth;
}

/// For font size, we can also use width to scale
double getProportionateFontSize(double inputSize) {
  return getProportionateScreenWidth(inputSize);
}

// Extensions for cleaner usage
extension SizeConfigExtension on num {
  double get h => getProportionateScreenHeight(this.toDouble());
  double get w => getProportionateScreenWidth(this.toDouble());
  double get sp => getProportionateFontSize(this.toDouble());
}
