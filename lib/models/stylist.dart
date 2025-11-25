class Stylist {
  final String id;
  final String userId;
  final String? bio;
  final double ratingAvg;
  final int ratingCount;
  final bool isActive;
  final List<String> skills;
  final String? avatarUrl;
  final Map<String, dynamic>? user;

  Stylist({
    required this.id,
    required this.userId,
    this.bio,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.isActive = true,
    this.skills = const [],
    this.avatarUrl,
    this.user,
  });

  factory Stylist.fromJson(Map<String, dynamic> json) {
    return Stylist(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] is String 
          ? json['userId'] 
          : json['userId']?['_id'] ?? json['userId']?['id'],
      bio: json['bio'],
      ratingAvg: (json['ratingAvg'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      skills: json['skills'] != null 
          ? List<String>.from(json['skills']) 
          : [],
      avatarUrl: json['avatarUrl'],
      user: json['userId'] is Map ? json['userId'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bio': bio,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'isActive': isActive,
      'skills': skills,
      'avatarUrl': avatarUrl,
    };
  }

  String get fullName => user?['fullName'] ?? 'Stylist';
  
  String get displayRating {
    if (ratingCount == 0) return 'Chưa có đánh giá';
    return '${ratingAvg.toStringAsFixed(1)} (${ratingCount} đánh giá)';
  }
}

