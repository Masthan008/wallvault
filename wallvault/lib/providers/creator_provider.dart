import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/creator_repository.dart';
import '../data/models/creator_model.dart';

final creatorRepositoryProvider = Provider<CreatorRepository>((ref) {
  return CreatorRepository();
});

final creatorProfileProvider = FutureProvider.family<CreatorModel?, String>((ref, creatorId) async {
  return ref.watch(creatorRepositoryProvider).getCreatorById(creatorId);
});
