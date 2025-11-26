/// Domain entity for Stylist
class StylistEntity {
  final String id;
  final String userId;
  final String? bio;
  final double ratingAvg;
  final int ratingCount;
  final bool isActive;
  final List<String> skills;
  final String? avatarUrl;

  StylistEntity({
    required this.id,
    required this.userId,
    this.bio,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.isActive = true,
    this.skills = const [],
    this.avatarUrl,
  });

  bool get hasRating => ratingCount > 0;
  
  String get displayRating {
    if (ratingCount == 0) return 'Chưa có đánh giá';
    return '${ratingAvg.toStringAsFixed(1)} (${ratingCount} đánh giá)';
  }
}

