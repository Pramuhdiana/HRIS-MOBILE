import 'package:flutter/material.dart';

/// Onboarding Model
/// Data model for onboarding items
class OnBoardingModel {
  final String title;
  final String subtitle;
  final String? lottieURL; // For network Lottie animations
  final String? lottieAssetPath; // For local Lottie JSON files
  final String? imagePath; // For PNG/JPG images
  final IconData? icon;

  const OnBoardingModel({
    required this.title,
    required this.subtitle,
    this.lottieURL,
    this.lottieAssetPath,
    this.imagePath,
    this.icon,
  });
}

/// Onboarding Items List
/// This will be populated with localized strings and images
List<OnBoardingModel> onboardintItems = [];
