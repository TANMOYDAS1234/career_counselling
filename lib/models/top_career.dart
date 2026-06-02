/// One of the top-3 AI career matches (POST /api/get-top-3-careers).
class TopCareer {
  const TopCareer({
    required this.title,
    required this.description,
    required this.matchScore,
  });

  final String title;
  final String description;

  /// Match percentage 0–100.
  final int matchScore;

  factory TopCareer.fromJson(Map<String, dynamic> json) => TopCareer(
        title: (json['title'] ?? '') as String,
        description: (json['description'] ?? '') as String,
        matchScore: (json['matchScore'] as num?)?.round() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'matchScore': matchScore,
      };
}
