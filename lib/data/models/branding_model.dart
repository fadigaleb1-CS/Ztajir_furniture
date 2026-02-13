import 'package:flutter/material.dart';

/// Model for branding data from API
class BrandingModel {
  final BrandingLogos logos;
  final BrandInfo brand;
  final BrandingColors colors;
  final BrandingTypography typography;
  final BrandingLayout layout;
  final BrandingSocial social;

  BrandingModel({
    required this.logos,
    required this.brand,
    required this.colors,
    required this.typography,
    required this.layout,
    required this.social,
  });

  factory BrandingModel.fromJson(Map<String, dynamic> json) {
    return BrandingModel(
      logos: BrandingLogos.fromJson(json['logos'] ?? {}),
      brand: BrandInfo.fromJson(json['brand'] ?? {}),
      colors: BrandingColors.fromJson(json['colors'] ?? {}),
      typography: BrandingTypography.fromJson(json['typography'] ?? {}),
      layout: BrandingLayout.fromJson(json['layout'] ?? {}),
      social: BrandingSocial.fromJson(json['social'] ?? {}),
    );
  }

  /// Default branding with fallback colors
  factory BrandingModel.defaultBranding() {
    return BrandingModel(
      logos: BrandingLogos.empty(),
      brand: BrandInfo.empty(),
      colors: BrandingColors.defaultColors(),
      typography: BrandingTypography.defaultTypography(),
      layout: BrandingLayout.defaultLayout(),
      social: BrandingSocial.empty(),
    );
  }
}

class BrandingLogos {
  final String? logo;
  final String? logoDark;
  final String? favicon;
  final String? coverImage;

  BrandingLogos({this.logo, this.logoDark, this.favicon, this.coverImage});

  factory BrandingLogos.fromJson(Map<String, dynamic> json) {
    return BrandingLogos(
      logo: json['logo'],
      logoDark: json['logo_dark'],
      favicon: json['favicon'],
      coverImage: json['cover_image'],
    );
  }

  factory BrandingLogos.empty() => BrandingLogos();
}

class BrandInfo {
  final String? displayName;
  final String? legalName;

  BrandInfo({this.displayName, this.legalName});

  factory BrandInfo.fromJson(Map<String, dynamic> json) {
    return BrandInfo(
      displayName: json['display_name'],
      legalName: json['legal_name'],
    );
  }

  factory BrandInfo.empty() => BrandInfo();
}

class BrandingColors {
  final ColorPair primary;
  final ColorPair secondary;
  final ColorPair accent;
  final StatusColors status;

  BrandingColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.status,
  });

  factory BrandingColors.fromJson(Map<String, dynamic> json) {
    return BrandingColors(
      primary: ColorPair.fromJson(json['primary'] ?? {}),
      secondary: ColorPair.fromJson(json['secondary'] ?? {}),
      accent: ColorPair.fromJson(json['accent'] ?? {}),
      status: StatusColors.fromJson(json['status'] ?? {}),
    );
  }

  factory BrandingColors.defaultColors() {
    return BrandingColors(
      primary: ColorPair(main: const Color(0xFF8B4513), text: Colors.white),
      secondary: ColorPair(main: const Color(0xFFFFFBF0), text: Colors.black),
      accent: ColorPair(main: const Color(0xFFF59E0B), text: Colors.black),
      status: StatusColors.defaultStatus(),
    );
  }
}

class ColorPair {
  final Color main;
  final Color text;

  ColorPair({required this.main, required this.text});

  factory ColorPair.fromJson(Map<String, dynamic> json) {
    return ColorPair(
      main: _hexToColor(json['main'] ?? '#8B4513'),
      text: _hexToColor(json['text'] ?? '#FFFFFF'),
    );
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

class StatusColors {
  final ColorPair success;
  final ColorPair error;
  final ColorPair warning;
  final ColorPair info;

  StatusColors({
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });

  factory StatusColors.fromJson(Map<String, dynamic> json) {
    return StatusColors(
      success: ColorPair.fromJson(json['success'] ?? {}),
      error: ColorPair.fromJson(json['error'] ?? {}),
      warning: ColorPair.fromJson(json['warning'] ?? {}),
      info: ColorPair.fromJson(json['info'] ?? {}),
    );
  }

  factory StatusColors.defaultStatus() {
    return StatusColors(
      success: ColorPair(main: const Color(0xFF25D366), text: Colors.white),
      error: ColorPair(main: Colors.red, text: Colors.white),
      warning: ColorPair(main: const Color(0xFFF59E0B), text: Colors.black),
      info: ColorPair(main: const Color(0xFF3B82F6), text: Colors.white),
    );
  }
}

class BrandingTypography {
  final String fontFamily;
  final String? headingFont;
  final String fontSizeBase;

  BrandingTypography({
    required this.fontFamily,
    this.headingFont,
    required this.fontSizeBase,
  });

  factory BrandingTypography.fromJson(Map<String, dynamic> json) {
    return BrandingTypography(
      fontFamily: json['font_family'] ?? 'Inter',
      headingFont: json['heading_font'],
      fontSizeBase: json['font_size_base'] ?? '16px',
    );
  }

  factory BrandingTypography.defaultTypography() {
    return BrandingTypography(fontFamily: 'Inter', fontSizeBase: '16px');
  }
}

class BrandingLayout {
  final String containerWidth;
  final String borderRadius;

  BrandingLayout({required this.containerWidth, required this.borderRadius});

  factory BrandingLayout.fromJson(Map<String, dynamic> json) {
    return BrandingLayout(
      containerWidth: json['container_width'] ?? '1280px',
      borderRadius: json['border_radius'] ?? '8px',
    );
  }

  factory BrandingLayout.defaultLayout() {
    return BrandingLayout(containerWidth: '1280px', borderRadius: '8px');
  }
}

class BrandingSocial {
  final String? website;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? linkedin;
  final String? youtube;
  final String? tiktok;
  final String? snapchat;

  BrandingSocial({
    this.website,
    this.facebook,
    this.twitter,
    this.instagram,
    this.linkedin,
    this.youtube,
    this.tiktok,
    this.snapchat,
  });

  factory BrandingSocial.fromJson(Map<String, dynamic> json) {
    return BrandingSocial(
      website: json['website'],
      facebook: json['facebook'],
      twitter: json['twitter'],
      instagram: json['instagram'],
      linkedin: json['linkedin'],
      youtube: json['youtube'],
      tiktok: json['tiktok'],
      snapchat: json['snapchat'],
    );
  }

  factory BrandingSocial.empty() => BrandingSocial();
}
