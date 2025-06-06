import 'dart:convert';
import 'package:flutter/material.dart';

class PlanPage extends StatelessWidget {
  final List<dynamic> plan;

  const PlanPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Training Plan'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: plan.length,
        itemBuilder: (context, index) {
          final week = plan[index];
          final weekNumber = week['week'];
          final days = week['plan'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week $weekNumber',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...days.map<Widget>((day) {
                      final dayName = day['day'].toString();
                      final activity = day['activity'];

                      Map<String, dynamic> parsed = {};
                      if (activity is Map<String, dynamic>) {
                        parsed = activity;
                      } else {
                        parsed = {
                          'No activity': 'No training details available.'
                        };
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...parsed.entries.map((entry) {
                                final label = entry.key;
                                final value = entry.value.toString();

                                Color? labelColor;
                                switch (label.toLowerCase()) {
                                  case 'warm up':
                                    labelColor = Colors.green[400];
                                    break;
                                  case 'main block':
                                    labelColor = Colors.blue[400];
                                    break;
                                  case 'technical/style focus':
                                    labelColor = Colors.red[400];
                                    break;
                                  case 'cooldown':
                                    labelColor = Colors.black;
                                    break;
                                  default:
                                    labelColor = Colors.grey[700];
                                }

                                final parts = value.split(". ");
                                final firstLine =
                                    parts.isNotEmpty ? parts.first : value;
                                final remainder = parts.length > 1
                                    ? parts.sublist(1).join(". ")
                                    : null;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(right: 8.0),
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: labelColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              label,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: labelColor,
                                              ),
                                            ),
                                            Text(firstLine),
                                            if (remainder != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4.0),
                                                child: Text(
                                                  remainder,
                                                  style: TextStyle(
                                                      color: Colors.grey[700]),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
