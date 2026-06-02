/// Stage-0 basic onboarding info (POST /api/save-onboarding & /api/get-onboarding).
class OnboardingData {
  const OnboardingData({
    this.name = '',
    this.classLevel = '',
    this.board = '',
    this.district = '',
    this.parentMobile = '',
  });

  /// Student name.
  final String name;

  /// "9" | "10" | "11" | "12" | "graduated".
  final String classLevel;

  /// "cbse" | "icse" | "state" | "ib" | "other".
  final String board;

  final String district;

  /// 10-digit parent/guardian mobile.
  final String parentMobile;

  factory OnboardingData.fromJson(Map<String, dynamic> json) => OnboardingData(
        name: (json['name'] ?? '') as String,
        classLevel: (json['classLevel'] ?? '') as String,
        board: (json['board'] ?? '') as String,
        district: (json['district'] ?? '') as String,
        parentMobile: (json['parentMobile'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'classLevel': classLevel,
        'board': board,
        'district': district,
        'parentMobile': parentMobile,
      };

  OnboardingData copyWith({
    String? name,
    String? classLevel,
    String? board,
    String? district,
    String? parentMobile,
  }) =>
      OnboardingData(
        name: name ?? this.name,
        classLevel: classLevel ?? this.classLevel,
        board: board ?? this.board,
        district: district ?? this.district,
        parentMobile: parentMobile ?? this.parentMobile,
      );

  bool get isComplete =>
      name.trim().isNotEmpty &&
      classLevel.isNotEmpty &&
      board.isNotEmpty &&
      district.trim().isNotEmpty &&
      parentMobile.trim().length == 10;
}
