import 'package:flutter/material.dart';

class NavBarSizes {
  final double iconSize;
  final double fontSize;
  final double padding;
  final String? shortenedLabel; // Optional: Use shorter text on small screens

  NavBarSizes({
    required this.iconSize,
    required this.fontSize,
    required this.padding,
    this.shortenedLabel,
  });
}

NavBarSizes getNavBarSizes(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 300) {
    // Very small phones (e.g., iPhone SE)
    return NavBarSizes(
      iconSize: 18,
      fontSize: 12,
      padding: 6,
      shortenedLabel: 'Hm', // Shortened label for "Home"
    );
  } else if (screenWidth < 400) {
    // Small phones
    return NavBarSizes(
      iconSize: 20,
      fontSize: 14,
      padding: 8,
    );
  } else if (screenWidth < 600) {
    // Most phones (default)
    return NavBarSizes(
      iconSize: 24,
      fontSize: 16,
      padding: 12,
    );
  } else if (screenWidth < 800) {
    // Small tablets
    return NavBarSizes(
      iconSize: 26,
      fontSize: 18,
      padding: 14,
    );
  } else {
    // Large tablets/desktops
    return NavBarSizes(
      iconSize: 28,
      fontSize: 18,
      padding: 16,
    );
  }
}
