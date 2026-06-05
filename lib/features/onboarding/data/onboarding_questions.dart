import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/question.dart';

/// The 12 subjects offered in Q8/Q9.
const kSubjects = [
  'Physics', 'Chemistry', 'Biology', 'Mathematics',
  'English', 'Bengali', 'Computer Science', 'Economics',
  'Geography', 'History', 'Political Science', 'Accountancy',
];

/// Marks bands for Q10 (value -> label).
const kMarkBands = [
  ('90+', 'Above 90'),
  ('80-90', '80-90'),
  ('70-80', '70-80'),
  ('60-70', '60-70'),
  ('below-60', 'Below 60'),
];

/// The six assessment modules.
const kModules = [
  ModuleInfo(1, 'The Opening', 1, 4),
  ModuleInfo(2, 'How Your Mind Works', 5, 7),
  ModuleInfo(3, "What You're Good At", 8, 11),
  ModuleInfo(4, 'Life Outside Marks', 12, 14),
  ModuleInfo(5, 'The Constraints', 15, 17),
  ModuleInfo(6, 'Final Calibration', 18, 20),
];

ModuleInfo moduleForQuestion(int q) =>
    kModules.firstWhere((m) => q >= m.firstQuestion && q <= m.lastQuestion);

/// All 20 questions, copied verbatim from the web onboarding flow.
const List<Question> kQuestions = [
  // ── Module 1 — The Opening ───────────────────────────────────────────────
  Question(
    number: 1, module: 1, fieldKey: 'whyHere', kind: QuestionKind.single,
    prompt: 'Why are you here today?',
    headerIcon: Icons.help_outline_rounded, headerColor: AppColors.primary100,
    options: [
      QuestionOption('no-idea', Icons.help_outline_rounded, 'I have no idea what to do after class 12'),
      QuestionOption('validate', Icons.check_circle_outline_rounded, "I have a plan but want to check if it's right"),
      QuestionOption('disagree', Icons.person_outline_rounded, 'My parents and I disagree about my career'),
      QuestionOption('explore', Icons.track_changes_rounded, 'I want to explore options before deciding'),
    ],
  ),
  Question(
    number: 2, module: 1, fieldKey: 'fiveYearVision', kind: QuestionKind.single, important: true,
    prompt: 'When you imagine yourself five years from now, which feels closest?',
    headerIcon: Icons.auto_awesome, headerColor: AppColors.secondary100,
    options: [
      QuestionOption('conventional', Icons.work_outline_rounded, 'Wearing a uniform or lab coat, doing focused expert work'),
      QuestionOption('enterprising', Icons.track_changes_rounded, 'Leading a team, presenting ideas, making decisions'),
      QuestionOption('artistic', Icons.palette_outlined, 'Creating something — designing, writing, building, performing'),
      QuestionOption('entrepreneurial', Icons.rocket_launch_outlined, "Running my own thing, even if it's small"),
    ],
  ),
  Question(
    number: 3, module: 1, fieldKey: 'careerThinking', kind: QuestionKind.text,
    prompt: "What's the one career you've been thinking about most?",
    headerIcon: Icons.track_changes_rounded, headerColor: AppColors.primary100,
    optional: true, maxLength: 50, placeholder: 'e.g., Doctor, Software Engineer, Designer...',
  ),
  Question(
    number: 4, module: 1, fieldKey: 'careerRuledOut', kind: QuestionKind.text,
    prompt: "And one career you've ruled out?",
    headerIcon: Icons.close_rounded, headerColor: AppColors.destructiveBg,
    optional: true, maxLength: 50, placeholder: 'e.g., Engineering, Medicine, Teaching...',
  ),

  // ── Module 2 — How Your Mind Works ────────────────────────────────────────
  Question(
    number: 5, module: 2, fieldKey: 'freeSunday', kind: QuestionKind.single, important: true,
    prompt: 'You have a free Sunday. Which sounds most fun?',
    headerIcon: Icons.videogame_asset_outlined, headerColor: AppColors.accent100,
    options: [
      QuestionOption('puzzle', Icons.lightbulb_outline_rounded, 'Solving a tricky puzzle or strategy game'),
      QuestionOption('friends', Icons.groups_outlined, 'Hanging out with friends and meeting new people'),
      QuestionOption('create', Icons.palette_outlined, 'Making something — drawing, music, video, writing'),
      QuestionOption('build', Icons.build_outlined, 'Fixing or building something with your hands'),
      QuestionOption('organize', Icons.folder_open_outlined, 'Organizing my room, my notes, my life'),
      QuestionOption('read', Icons.menu_book_outlined, 'Reading about how the world works'),
    ],
  ),
  Question(
    number: 6, module: 2, fieldKey: 'groupRole', kind: QuestionKind.single, important: true,
    prompt: 'A group project lands in your lap. Without thinking, which role do you grab?',
    headerIcon: Icons.groups_outlined, headerColor: AppColors.primary100,
    options: [
      QuestionOption('plan', Icons.track_changes_rounded, 'The one who plans and divides the work'),
      QuestionOption('research', Icons.menu_book_outlined, 'The one who does the research and analysis'),
      QuestionOption('present', Icons.co_present_outlined, 'The one who makes it look good in the final presentation'),
      QuestionOption('motivate', Icons.favorite_outline_rounded, 'The one who keeps everyone motivated and unstuck'),
      QuestionOption('execute', Icons.handyman_outlined, 'The one who actually builds or executes it'),
    ],
  ),
  Question(
    number: 7, module: 2, fieldKey: 'jobBothers', kind: QuestionKind.single, important: true,
    prompt: 'Which of these would bother you most in a future job?',
    headerIcon: Icons.person_off_outlined, headerColor: AppColors.destructiveBg,
    options: [
      QuestionOption('repetitive', Icons.repeat_rounded, 'Repeating the same task every day'),
      QuestionOption('decisions', Icons.balance_rounded, "Being responsible for big decisions and the blame if they're wrong"),
      QuestionOption('alone', Icons.person_off_outlined, 'Working alone without much human contact'),
      QuestionOption('no-result', Icons.visibility_outlined, 'Not being able to see a clear result of my work'),
      QuestionOption('strict-rules', Icons.shield_outlined, 'Having to follow strict rules and procedures'),
    ],
  ),

  // ── Module 3 — What You're Good At ────────────────────────────────────────
  Question(
    number: 8, module: 3, fieldKey: 'favoriteSubjects', kind: QuestionKind.subjectMulti, important: true,
    prompt: 'Pick your three favorite subjects this year',
    headerIcon: Icons.menu_book_outlined, headerColor: AppColors.primary100,
    maxSelect: 3, minSelect: 1,
  ),
  Question(
    number: 9, module: 3, fieldKey: 'difficultSubject', kind: QuestionKind.subjectSingle,
    prompt: 'Now pick the subject you find most difficult',
    headerIcon: Icons.trending_up_rounded, headerColor: AppColors.amber100,
  ),
  Question(
    number: 10, module: 3, fieldKey: 'subjectMarks', kind: QuestionKind.marks, important: true,
    prompt: 'Your marks in the subjects you picked as favorites',
    headerIcon: Icons.workspace_premium_outlined, headerColor: AppColors.emerald100,
  ),
  Question(
    number: 11, module: 3, fieldKey: 'studyExperience', kind: QuestionKind.single, important: true,
    prompt: 'When you study a subject you genuinely enjoy, what happens?',
    headerIcon: Icons.schedule_rounded, headerColor: AppColors.secondary100,
    options: [
      QuestionOption('flow', Icons.schedule_rounded, 'I lose track of time and hours pass'),
      QuestionOption('work', Icons.trending_up_rounded, 'I do well but it still feels like work'),
      QuestionOption('class-only', Icons.groups_outlined, 'I enjoy the class but struggle to study alone'),
      QuestionOption('videos', Icons.ondemand_video_outlined, 'I prefer learning from videos and discussion over textbooks'),
    ],
  ),

  // ── Module 4 — Life Outside Marks ─────────────────────────────────────────
  Question(
    number: 12, module: 4, fieldKey: 'outsideActivities', kind: QuestionKind.multi,
    prompt: 'Outside studies, what do you actually spend time on?',
    headerIcon: Icons.favorite_outline_rounded, headerColor: AppColors.secondary100,
    maxSelect: 3, minSelect: 1,
    options: [
      QuestionOption('sports', Icons.fitness_center_rounded, 'Sports / physical activity'),
      QuestionOption('creative', Icons.music_note_outlined, 'Music, art, or creative hobbies'),
      QuestionOption('gaming', Icons.videogame_asset_outlined, 'Gaming'),
      QuestionOption('reading', Icons.menu_book_outlined, 'Reading (non-textbook)'),
      QuestionOption('social-media', Icons.chat_bubble_outline_rounded, 'Social media and chatting with friends'),
      QuestionOption('helping', Icons.home_outlined, 'Helping at home, family business, or in the community'),
      QuestionOption('tech', Icons.code_rounded, 'Building / coding / experimenting with tech'),
      QuestionOption('none', Icons.coffee_outlined, 'Honestly, just studies and rest — no time for hobbies'),
    ],
  ),
  Question(
    number: 13, module: 4, fieldKey: 'externalValidation', kind: QuestionKind.single,
    prompt: 'Has anyone ever told you "you\'d be great at ___"?',
    headerIcon: Icons.thumb_up_outlined, headerColor: AppColors.primary100,
    options: [
      QuestionOption('agree', Icons.thumb_up_outlined, 'Yes, and I agree'),
      QuestionOption('unsure', Icons.sentiment_neutral_rounded, "Yes, but I'm not sure"),
      QuestionOption('disagree', Icons.thumb_down_outlined, "Yes, but I don't want to do that"),
      QuestionOption('no', Icons.help_outline_rounded, 'No, not really'),
    ],
  ),
  Question(
    number: 14, module: 4, fieldKey: 'selfInitiated', kind: QuestionKind.text,
    prompt: 'Tell me about something you did in the last year without anyone asking you to',
    headerIcon: Icons.edit_outlined, headerColor: AppColors.secondary100,
    optional: true, maxLength: 200,
    placeholder: 'e.g., Started a YouTube channel, organized a school event, learned a new skill...',
  ),

  // ── Module 5 — The Constraints ────────────────────────────────────────────
  Question(
    number: 15, module: 5, fieldKey: 'studyLocation', kind: QuestionKind.singleAsList,
    prompt: 'Where are you open to studying?',
    headerIcon: Icons.map_outlined, headerColor: AppColors.primary100,
    options: [
      QuestionOption('kolkata', Icons.location_on_outlined, 'Only Kolkata'),
      QuestionOption('west-bengal', Icons.map_outlined, 'Anywhere in West Bengal'),
      QuestionOption('india', Icons.location_on_outlined, 'Anywhere in India'),
      QuestionOption('abroad', Icons.public_rounded, 'Open to studying abroad if it works out'),
    ],
  ),
  Question(
    number: 16, module: 5, fieldKey: 'familyBudget', kind: QuestionKind.single,
    prompt: 'Have you talked to your family about the cost of higher education?',
    headerIcon: Icons.attach_money_rounded, headerColor: AppColors.accent100,
    options: [
      QuestionOption('clear-budget', Icons.check_circle_outline_rounded, 'Yes, and we have a clear budget'),
      QuestionOption('depends', Icons.help_outline_rounded, 'Yes, but it depends on the course'),
      QuestionOption('not-really', Icons.sentiment_neutral_rounded, 'Not really'),
      QuestionOption('no-money-factor', Icons.auto_awesome, "I'd rather not factor money into this right now"),
    ],
  ),
  Question(
    number: 17, module: 5, fieldKey: 'careerValues', kind: QuestionKind.multi, important: true,
    prompt: 'When you think about your career, which feels most important?',
    headerIcon: Icons.favorite_outline_rounded, headerColor: AppColors.secondary100,
    maxSelect: 2, minSelect: 2,
    options: [
      QuestionOption('earning', Icons.trending_up_rounded, 'Earning well, sooner rather than later'),
      QuestionOption('interest', Icons.favorite_outline_rounded, 'Doing work that genuinely interests me'),
      QuestionOption('family-pride', Icons.workspace_premium_outlined, 'A career my family will be proud of'),
      QuestionOption('stability', Icons.shield_outlined, 'Stability and security'),
      QuestionOption('impact', Icons.groups_outlined, 'Making a real impact on people or society'),
    ],
  ),

  // ── Module 6 — Final Calibration ──────────────────────────────────────────
  Question(
    number: 18, module: 6, fieldKey: 'planningStyle', kind: QuestionKind.single,
    prompt: 'Pick the statement that sounds most like you',
    headerIcon: Icons.navigation_outlined, headerColor: AppColors.primary100,
    options: [
      QuestionOption('clear-plan', Icons.description_outlined, "I'd rather have a clear plan and follow it"),
      QuestionOption('options', Icons.navigation_outlined, "I'd rather have options and figure it out as I go"),
      QuestionOption('others', Icons.groups_outlined, "I'd rather have someone tell me what's worked for others"),
      QuestionOption('try-things', Icons.bolt_rounded, "I'd rather try things and see what fits"),
    ],
  ),
  Question(
    number: 19, module: 6, fieldKey: 'stressResponse', kind: QuestionKind.single,
    prompt: 'When something is stressful, what do you usually do?',
    headerIcon: Icons.error_outline_rounded, headerColor: AppColors.amber100,
    options: [
      QuestionOption('power-through', Icons.bolt_rounded, 'Power through and finish it'),
      QuestionOption('take-break', Icons.pause_circle_outline_rounded, 'Take a break and come back to it'),
      QuestionOption('talk', Icons.forum_outlined, 'Talk to someone about it'),
      QuestionOption('procrastinate', Icons.trending_down_rounded, 'Get overwhelmed and procrastinate, honestly'),
    ],
  ),
  Question(
    number: 20, module: 6, fieldKey: 'surpriseReaction', kind: QuestionKind.single,
    prompt: 'Last one — if your career assessment told you something surprising, would you...?',
    headerIcon: Icons.auto_awesome, headerColor: AppColors.secondary100,
    options: [
      QuestionOption('excited', Icons.sentiment_satisfied_alt_rounded, 'Be excited to explore it'),
      QuestionOption('skeptical', Icons.help_outline_rounded, 'Be skeptical but curious'),
      QuestionOption('wrong', Icons.close_rounded, 'Feel like the system got it wrong'),
      QuestionOption('counselor', Icons.forum_outlined, 'Want to talk to a counselor about it'),
    ],
  ),
];

Question questionByNumber(int n) => kQuestions.firstWhere((q) => q.number == n);
