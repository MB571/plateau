import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const _apiKey =
      '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';
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  static Future<String?> generateClimbingPlan({
    required String maxHang20mm,
    required String maxHang15mm,
    required String maxHang10mm,
    required String maxPullups,
    required String maxBoulderGrade,
    required String maxLeadGrade,
    required String preferredStyle,
    required String worstStyle,
    required bool gymAccess,
    required bool hangboardAccess,
    required String sessionMinutes,
    required String daysPerWeek,
    String? goalType,
    String? goalGrade,
  }) async {
    final prompt = '''
You are a world-class climbing coach. Generate a climbing training plan in **VALID JSON ONLY**.

⚠️ HARD REQUIREMENTS:
- Do not include any text or explanations — ONLY return a pure JSON array.
- The array must contain **between 8 and 12 weeks** exactly. If not, your output will be rejected.
- The plan MUST contain **$daysPerWeek sessions per week**, each lasting exactly **$sessionMinutes minutes** total.
- Every training session MUST include these 4 sections with times:
  - "Warm up"
  - "Main Block"
  - "Technical/Style Focus"
  - "Cooldown"
- Each section MUST include a **second sentence** that is a longer, lay summary — explaining what the climber should feel, aim for, or develop in this section (at least 1–2 sentences).
- Times must be included, and the total must match $sessionMinutes per day.
- Absolutely no duplicate sessions. Each session must be unique in structure or focus.
- Include rest or deload weeks (e.g., week 5 or 6) with lower intensity.
- Hangboard must not be included if the user has no access or poor hang times (< 7s).

🧗 USER PROFILE:
- Max hang 20mm: $maxHang20mm s
- Max hang 15mm: $maxHang15mm s
- Max hang 10mm: $maxHang10mm s
- Max pull-ups: $maxPullups
- Max bouldering grade: $maxBoulderGrade
- Max lead grade: $maxLeadGrade
- Preferred style: $preferredStyle
- Weakest style: $worstStyle
- Gym access: ${gymAccess ? 'Yes' : 'No'}
- Hangboard access: ${hangboardAccess ? 'Yes' : 'No'}
- Days/week: $daysPerWeek
- Session duration: $sessionMinutes minutes
${goalType != null && goalGrade != null ? '- Goal: Improve $goalType grade to $goalGrade' : ''}

🎯 PLAN STRATEGY:
- Start easy, then gradually increase intensity.
- Use games (e.g., silent feet, add-a-move) especially early on.
- Give a more detailed session description under each.
- Introduce preferred style later; focus on weaknesses first.
- Progressively challenge climbers with higher grades or volume.
- Provide exact timing for each section to match session duration.
- Warm ups and cooldowns can be similar each week.
- Example of valid JSON structure:

[
  {
    "week": 1,
    "plan": [
      {
        "day": "Monday",
        "activity": {
          "Warm up": "15 min - Easy boulders and shoulder mobility. Focus on warming up the shoulders and fingers. Don't rush this part!",
          "Main Block": "25 min - 4x4 on V2 with 3 min rest. This is 4 sets of 4 problems, climbing each problem 4 times in a row. Focus on maintaining a steady pace and breathing, if you need a longer break take one.",
          "Technical/Style Focus": "10 min - Silent feet game on slab. Dont let your feet make noise when you step. This will help you focus on foot placement and body positioning.",
          "Cooldown": "5 min - Antagonist exercises and stretching. Antagonist exercises are usually push-ups or dips. Stretch your shoulders and fingers."
        }
      },
      {
        "day": "Wednesday",
        "activity": {
          "Warm up": "15 min - Mobility and light climbing. Aim to climb reachy problems to warm up your shoulders and fingers. Dont get too out of breath.",
          "Main Block": "25 min - Hangboard: 20mm edge 3x10s, 3 min rest. Focus on maintaining a steady grip and breathing. If you feel pain, stop immediately.",
          "Technical/Style Focus": "10 min - Crimp foot placement drills. Focus on foot placement and body positioning. This will help you climb more efficiently.",
          "Cooldown": "5 min - Wrist stretches and light climbing. Focus on relaxing your shoulders and fingers. This will help you recover faster."
        }
      }
    ]
  }
]

🚫 DO NOT:
- Include any text outside the JSON array.
- Return fewer than 8 weeks or more than 12 weeks.
- Return duplicate sessions.
- Exclude timing or detail.

ONLY RETURN VALID JSON OR THE RESPONSE WILL BE REJECTED.
''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "temperature": 0.5,
        "stop": ["```", "###", "---"]
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final String content = decoded['choices'][0]['message']['content'];
      return content;
    } else {
      print('OpenAI API error: ${response.body}');
      return null;
    }
  }
}
