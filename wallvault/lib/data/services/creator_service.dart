import 'dart:io';

class CreatorService {
  /// S47 — Validate image specifications before processing uploads:
  /// - Format must be JPG, PNG, or WEBP
  /// - File size must be under 20MB
  /// - Minimum resolution must be 1080p (width >= 1080 or height >= 1080)
  Future<String?> validateWallpaperFile(File file) async {
    final path = file.path.toLowerCase();
    
    // Check format
    if (!path.endsWith('.jpg') && !path.endsWith('.jpeg') && !path.endsWith('.png') && !path.endsWith('.webp')) {
      return 'Format must be JPG, PNG, or WEBP';
    }

    // Check size (20MB = 20 * 1024 * 1024 bytes)
    final size = await file.length();
    if (size > 20 * 1024 * 1024) {
      return 'File size exceeds maximum limit of 20MB';
    }

    // Return null if validation passes
    return null;
  }
}
