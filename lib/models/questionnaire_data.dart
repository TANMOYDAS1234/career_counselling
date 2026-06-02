/// The full assessment payload (POST /api/save-questionnaire as `questionnaireData`).
///
/// Field names match the backend `user_session` mapping exactly. Single-choice
/// answers are stored as their option keys (e.g. whyHere = "no-idea"); the
/// human-readable labels live on the screens / report.
class QuestionnaireData {
  const QuestionnaireData({
    // Module 1 — Motivation
    this.whyHere,
    this.fiveYearVision,
    this.careerThinking,
    this.careerRuledOut,
    // Module 2 — Cognitive & work style
    this.freeSunday,
    this.groupRole,
    this.jobBothers,
    // Module 3 — Academic
    this.favoriteSubjects = const [],
    this.difficultSubject,
    this.subjectMarks = const {},
    this.studyExperience,
    // Module 4 — Behavioral
    this.outsideActivities = const [],
    this.externalValidation,
    this.selfInitiated,
    // Module 5 — Constraints & values
    this.studyLocation = const [],
    this.familyBudget,
    this.careerValues = const [],
    // Module 6 — Final calibration
    this.planningStyle,
    this.stressResponse,
    this.surpriseReaction,
    // Aptitude game scores (0–8 each)
    this.numberSenseScore,
    this.wordSenseScore,
    this.shapeSenseScore,
    this.logicSenseScore,
    // Persistence games
    this.persistenceEffortRating,
    this.persistenceApproachStyle,
    this.persistenceCounselorFlags = const [],
    this.persistenceHighestTier,
    this.constraintGridApproach,
    this.constraintGridSolved,
    this.constraintGridCounselorFlag,
    this.blackBoxApproach,
    this.blackBoxSolved,
    this.blackBoxAbandonedLastGuess,
    this.blackBoxCounselorFlag,
  });

  final String? whyHere;
  final String? fiveYearVision;
  final String? careerThinking;
  final String? careerRuledOut;

  final String? freeSunday;
  final String? groupRole;
  final String? jobBothers;

  final List<String> favoriteSubjects;
  final String? difficultSubject;
  final Map<String, String> subjectMarks;
  final String? studyExperience;

  final List<String> outsideActivities;
  final String? externalValidation;
  final String? selfInitiated;

  final List<String> studyLocation;
  final String? familyBudget;
  final List<String> careerValues;

  final String? planningStyle;
  final String? stressResponse;
  final String? surpriseReaction;

  final int? numberSenseScore;
  final int? wordSenseScore;
  final int? shapeSenseScore;
  final int? logicSenseScore;

  final int? persistenceEffortRating;
  final String? persistenceApproachStyle;
  final List<String> persistenceCounselorFlags;
  final int? persistenceHighestTier;
  final String? constraintGridApproach;
  final bool? constraintGridSolved;
  final bool? constraintGridCounselorFlag;
  final String? blackBoxApproach;
  final bool? blackBoxSolved;
  final bool? blackBoxAbandonedLastGuess;
  final bool? blackBoxCounselorFlag;

  Map<String, dynamic> toJson() => {
        'whyHere': whyHere,
        'fiveYearVision': fiveYearVision,
        'careerThinking': careerThinking,
        'careerRuledOut': careerRuledOut,
        'freeSunday': freeSunday,
        'groupRole': groupRole,
        'jobBothers': jobBothers,
        'favoriteSubjects': favoriteSubjects,
        'difficultSubject': difficultSubject,
        'subjectMarks': subjectMarks,
        'studyExperience': studyExperience,
        'outsideActivities': outsideActivities,
        'externalValidation': externalValidation,
        'selfInitiated': selfInitiated,
        'studyLocation': studyLocation,
        'familyBudget': familyBudget,
        'careerValues': careerValues,
        'planningStyle': planningStyle,
        'stressResponse': stressResponse,
        'surpriseReaction': surpriseReaction,
        'numberSenseScore': numberSenseScore,
        'wordSenseScore': wordSenseScore,
        'shapeSenseScore': shapeSenseScore,
        'logicSenseScore': logicSenseScore,
        'persistenceEffortRating': persistenceEffortRating,
        'persistenceApproachStyle': persistenceApproachStyle,
        'persistenceCounselorFlags': persistenceCounselorFlags,
        'persistenceHighestTier': persistenceHighestTier,
        'constraintGridApproach': constraintGridApproach,
        'constraintGridSolved': constraintGridSolved,
        'constraintGridCounselorFlag': constraintGridCounselorFlag,
        'blackBoxApproach': blackBoxApproach,
        'blackBoxSolved': blackBoxSolved,
        'blackBoxAbandonedLastGuess': blackBoxAbandonedLastGuess,
        'blackBoxCounselorFlag': blackBoxCounselorFlag,
      };

  QuestionnaireData copyWith({
    String? whyHere,
    String? fiveYearVision,
    String? careerThinking,
    String? careerRuledOut,
    String? freeSunday,
    String? groupRole,
    String? jobBothers,
    List<String>? favoriteSubjects,
    String? difficultSubject,
    Map<String, String>? subjectMarks,
    String? studyExperience,
    List<String>? outsideActivities,
    String? externalValidation,
    String? selfInitiated,
    List<String>? studyLocation,
    String? familyBudget,
    List<String>? careerValues,
    String? planningStyle,
    String? stressResponse,
    String? surpriseReaction,
    int? numberSenseScore,
    int? wordSenseScore,
    int? shapeSenseScore,
    int? logicSenseScore,
    int? persistenceEffortRating,
    String? persistenceApproachStyle,
    List<String>? persistenceCounselorFlags,
    int? persistenceHighestTier,
    String? constraintGridApproach,
    bool? constraintGridSolved,
    bool? constraintGridCounselorFlag,
    String? blackBoxApproach,
    bool? blackBoxSolved,
    bool? blackBoxAbandonedLastGuess,
    bool? blackBoxCounselorFlag,
  }) {
    return QuestionnaireData(
      whyHere: whyHere ?? this.whyHere,
      fiveYearVision: fiveYearVision ?? this.fiveYearVision,
      careerThinking: careerThinking ?? this.careerThinking,
      careerRuledOut: careerRuledOut ?? this.careerRuledOut,
      freeSunday: freeSunday ?? this.freeSunday,
      groupRole: groupRole ?? this.groupRole,
      jobBothers: jobBothers ?? this.jobBothers,
      favoriteSubjects: favoriteSubjects ?? this.favoriteSubjects,
      difficultSubject: difficultSubject ?? this.difficultSubject,
      subjectMarks: subjectMarks ?? this.subjectMarks,
      studyExperience: studyExperience ?? this.studyExperience,
      outsideActivities: outsideActivities ?? this.outsideActivities,
      externalValidation: externalValidation ?? this.externalValidation,
      selfInitiated: selfInitiated ?? this.selfInitiated,
      studyLocation: studyLocation ?? this.studyLocation,
      familyBudget: familyBudget ?? this.familyBudget,
      careerValues: careerValues ?? this.careerValues,
      planningStyle: planningStyle ?? this.planningStyle,
      stressResponse: stressResponse ?? this.stressResponse,
      surpriseReaction: surpriseReaction ?? this.surpriseReaction,
      numberSenseScore: numberSenseScore ?? this.numberSenseScore,
      wordSenseScore: wordSenseScore ?? this.wordSenseScore,
      shapeSenseScore: shapeSenseScore ?? this.shapeSenseScore,
      logicSenseScore: logicSenseScore ?? this.logicSenseScore,
      persistenceEffortRating: persistenceEffortRating ?? this.persistenceEffortRating,
      persistenceApproachStyle: persistenceApproachStyle ?? this.persistenceApproachStyle,
      persistenceCounselorFlags: persistenceCounselorFlags ?? this.persistenceCounselorFlags,
      persistenceHighestTier: persistenceHighestTier ?? this.persistenceHighestTier,
      constraintGridApproach: constraintGridApproach ?? this.constraintGridApproach,
      constraintGridSolved: constraintGridSolved ?? this.constraintGridSolved,
      constraintGridCounselorFlag: constraintGridCounselorFlag ?? this.constraintGridCounselorFlag,
      blackBoxApproach: blackBoxApproach ?? this.blackBoxApproach,
      blackBoxSolved: blackBoxSolved ?? this.blackBoxSolved,
      blackBoxAbandonedLastGuess: blackBoxAbandonedLastGuess ?? this.blackBoxAbandonedLastGuess,
      blackBoxCounselorFlag: blackBoxCounselorFlag ?? this.blackBoxCounselorFlag,
    );
  }
}
