import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';

/// Circular user avatar: shows the profile picture (a base64 data URL stored on
/// the user) when available, otherwise the user's initials on a gradient.
/// Used in the app bar and the profile screen so the photo appears everywhere.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.imageData,
    required this.fallback,
    this.size = 28,
    this.fontSize = 11,
  });

  final String? imageData;
  final String fallback;
  final double size;
  final double fontSize;

  static Uint8List? decode(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      final raw = data.contains(',') ? data.substring(data.indexOf(',') + 1) : data;
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  static String initialsOf(String s) {
    final parts = s.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.map((p) => p[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bytes = decode(imageData);
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: bytes != null
          ? Image.memory(bytes, width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true)
          : Text(
              initialsOf(fallback),
              style: TextStyle(color: AppColors.white, fontSize: fontSize, fontWeight: FontWeight.w700),
            ),
    );
  }
}
