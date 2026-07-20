import 'dart:math';

class GamificationService {
  /// S51 — User XP level calculations: level = floor(sqrt(xp / 100))
  int calculateUserLevel(int xp) {
    if (xp <= 0) return 1;
    return max(1, sqrt(xp / 100).floor());
  }

  /// S51 — Check streak milestones (e.g. 7, 30, 100 days consecutive logins)
  String? checkStreakMilestoneBadge(int currentStreak) {
    if (currentStreak == 7) return 'Week Warrior 🏆';
    if (currentStreak == 30) return 'Month Master 👑';
    if (currentStreak == 100) return 'Centurion 🌟';
    return null;
  }

  /// S51 — Creator Tier definitions
  String getCreatorTierLabel(int level) {
    if (level >= 5) return 'Legend 👑';
    if (level == 4) return 'Star ⭐';
    if (level == 3) return 'Bloom 🌸';
    if (level == 2) return 'Sprout 🌿';
    return 'Seedling 🌱';
  }
}
