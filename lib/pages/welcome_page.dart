// full WelcomePage.dart with session time check and grade increase cap
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../services/openai_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _hang20mmController = TextEditingController();
  final TextEditingController _hang15mmController = TextEditingController();
  final TextEditingController _hang10mmController = TextEditingController();
  final TextEditingController _pullupsController = TextEditingController();
  final TextEditingController _sessionMinutesController =
      TextEditingController();

  String? _boulderGrade;
  String? _leadGrade;
  String? _preferredStyle;
  String? _worstStyle;
  String? _daysPerWeek;
  bool _gymAccess = false;
  bool _hangboardAccess = false;

  String? _goalType;
  double _gradeIncrease = 0.5;
  bool _isLoading = false;

  final List<String> boulderGrades = [
    'V0',
    'V1',
    'V2',
    'V3',
    'V4',
    'V5',
    'V6',
    'V7',
    'V8',
    'V9',
    'V10'
  ];

  final List<Color> ambitionColors = [
    Colors.red[100]!,
    Colors.red[300]!,
    Colors.red[500]!,
    Colors.red[700]!,
    Colors.red[900]!,
    Colors.red[900]!,
  ];

  int gradeToNumeric(String grade, String type) {
    if (type == 'boulder') {
      const boulder = [
        'V0',
        'V1',
        'V2',
        'V3',
        'V4',
        'V5',
        'V6',
        'V7',
        'V8',
        'V9',
        'V10',
        'V11',
        'V12',
        'V13',
        'V14'
      ];
      return boulder.indexOf(grade);
    } else {
      const lead = [
        '5a',
        '5b',
        '5c',
        '6a',
        '6a+',
        '6b',
        '6b+',
        '6c',
        '6c+',
        '7a',
        '7a+',
        '7b',
        '7b+',
        '7c',
        '7c+',
        '8a',
        '8a+'
      ];
      return lead.indexOf(grade);
    }
  }

  @override
  Widget build(BuildContext context) {
    double minIncrease = 0.5;
    double maxIncrease = 2.0;

    int boulderIndex =
        _boulderGrade != null ? gradeToNumeric(_boulderGrade!, 'boulder') : -1;
    int leadIndex =
        _leadGrade != null ? gradeToNumeric(_leadGrade!, 'lead') : -1;

    if (_goalType == 'bouldering') {
      if (boulderIndex >= 9)
        maxIncrease = 1.0;
      else if (boulderIndex >= 6) maxIncrease = 1.5;
    }
    if (_goalType == 'lead') {
      if (leadIndex >= 14)
        maxIncrease = 1.0;
      else if (leadIndex >= 10) maxIncrease = 1.5;
    }

    int colorIndex = ((_gradeIncrease - minIncrease) * 2)
        .round()
        .clamp(0, ambitionColors.length - 1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Plateau',
                    style: GoogleFonts.baumans(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildSectionTitle('Hangboard'),
                _buildTextField(
                    _hang20mmController, 'Max Hang (20mm) in seconds'),
                _buildTextField(
                    _hang15mmController, 'Max Hang (15mm) in seconds'),
                _buildTextField(
                    _hang10mmController, 'Max Hang (10mm) in seconds'),
                _buildTextField(_pullupsController, 'Max Pull-ups'),
                const SizedBox(height: 16),
                _buildSectionTitle('Current Grades'),
                _buildDropdown('Max Bouldering Grade', boulderGrades,
                    (val) => setState(() => _boulderGrade = val)),
                _buildDropdown(
                  'Max Lead Grade',
                  [
                    '5a',
                    '5b',
                    '5c',
                    '6a',
                    '6a+',
                    '6b',
                    '6b+',
                    '6c',
                    '6c+',
                    '7a',
                    '7a+',
                    '7b',
                    '7b+',
                    '7c',
                    '7c+'
                  ],
                  (val) => setState(() => _leadGrade = val),
                ),
                _buildDropdown(
                    'Preferred Style',
                    ['Tech', 'Crimpy', 'Power', 'Overhang', 'Slab'],
                    (val) => setState(() => _preferredStyle = val)),
                _buildDropdown(
                    'Worst Style',
                    ['Tech', 'Crimpy', 'Power', 'Overhang', 'Slab'],
                    (val) => setState(() => _worstStyle = val)),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Has Gym Access?'),
                  value: _gymAccess,
                  onChanged: (val) => setState(() => _gymAccess = val),
                ),
                SwitchListTile(
                  title: const Text('Has Hangboard Access?'),
                  value: _hangboardAccess,
                  onChanged: (val) => setState(() => _hangboardAccess = val),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Training Availability'),
                _buildTextField(
                    _sessionMinutesController, 'Session length in minutes'),
                _buildDropdown(
                    'Days training per week',
                    ['1', '2', '3', '4', '5', '6', '7'],
                    (val) => setState(() => _daysPerWeek = val)),
                const SizedBox(height: 16),
                _buildSectionTitle('Goal'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _goalType == 'bouldering'
                            ? Colors.green
                            : Colors.grey[300],
                      ),
                      onPressed: () => setState(() => _goalType = 'bouldering'),
                      child: const Text('Bouldering'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _goalType == 'lead'
                            ? Colors.green
                            : Colors.grey[300],
                      ),
                      onPressed: () => setState(() => _goalType = 'lead'),
                      child: const Text('Lead'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_goalType != null) ...[
                  Text(
                      'Grade point increase: ${_gradeIncrease.toStringAsFixed(1)}'),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: ambitionColors[colorIndex],
                      thumbColor: ambitionColors[colorIndex],
                    ),
                    child: Slider(
                      value: _gradeIncrease,
                      min: minIncrease,
                      max: maxIncrease,
                      divisions: ((maxIncrease - minIncrease) * 2).round(),
                      label: _gradeIncrease.toStringAsFixed(1),
                      onChanged: (val) {
                        setState(() => _gradeIncrease = val);
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final minutes =
                        int.tryParse(_sessionMinutesController.text) ?? 0;
                    final days = int.tryParse(_daysPerWeek ?? '0') ?? 0;
                    final weeklyTotal = minutes * days;

                    if (weeklyTotal < 85) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Training plans require at least 85 minutes per week.')),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);

                    final planJson = await OpenAIService.generateClimbingPlan(
                      maxHang20mm: _hang20mmController.text,
                      maxHang15mm: _hang15mmController.text,
                      maxHang10mm: _hang10mmController.text,
                      maxPullups: _pullupsController.text,
                      maxBoulderGrade: _boulderGrade ?? '',
                      maxLeadGrade: _leadGrade ?? '',
                      preferredStyle: _preferredStyle ?? '',
                      worstStyle: _worstStyle ?? '',
                      gymAccess: _gymAccess,
                      hangboardAccess: _hangboardAccess,
                      sessionMinutes: _sessionMinutesController.text,
                      daysPerWeek: _daysPerWeek ?? '',
                      goalType: _goalType,
                      goalGrade: _gradeIncrease.toStringAsFixed(1),
                    );

                    setState(() => _isLoading = false);

                    if (planJson != null) {
                      try {
                        final decoded = jsonDecode(planJson);
                        print('Decoded plan:');
                        print(decoded);

                        if (decoded is List &&
                            decoded.isNotEmpty &&
                            decoded[0]['plan'] != null) {
                          Navigator.pushNamed(context, '/plan',
                              arguments: decoded);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Plan was empty or misformatted.')),
                          );
                        }
                      } catch (e) {
                        print('JSON decode error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to decode plan JSON.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('No response from OpenAI.')),
                      );
                    }
                  },
                  child: const Text('Generate Plan'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Generating your plan...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: Colors.white,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildDropdown(
      String label, List<String> options, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: label.contains('Bouldering')
            ? _boulderGrade
            : (label.contains('Lead') ? _leadGrade : null),
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
