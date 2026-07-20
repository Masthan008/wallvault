import 'dart:io';

class CloudinaryService {
  final String cloudName = 'dn30vxcoq';
  final String apiKey = '972246177422269';
  final String apiSecret = 'JMJq080FCoudvQVTzncRW4Ghd84';

  /// Uploads a file and returns the secure URL.
  Future<String> uploadImage(File file, {String folder = 'wallpapers'}) async {
    // TODO: Connect to Cloudinary API and upload
    await Future.delayed(const Duration(seconds: 2));
    return 'https://res.cloudinary.com/$cloudName/image/upload/v12345/placeholder.jpg';
  }
}
