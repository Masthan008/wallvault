import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Ultra-Fast Glassmorphic Cached Image Widget for WallVault.
/// Automatically handles assets vs network URLs with disk caching, memory bounds, and Shimmer placeholders.
class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final BorderRadius? borderRadius;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isAsset = imageUrl.startsWith('assets/');

    Widget imageWidget;
    if (isAsset) {
      imageWidget = Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildErrorFallback(),
      );
    } else if (imageUrl.isEmpty) {
      imageWidget = _buildErrorFallback();
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        memCacheWidth: memCacheWidth ?? 600,
        memCacheHeight: memCacheHeight ?? 1000,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.bgCard,
          highlightColor: AppColors.bgElevated,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            color: AppColors.bgCard,
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorFallback(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildErrorFallback() {
    return Image.asset(
      'assets/images/prebuilt_03.png',
      fit: fit,
      width: width,
      height: height,
    );
  }
}
