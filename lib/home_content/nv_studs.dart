import 'package:flutter/material.dart';

// --- GreenTalkies Color Palette (Imported for consistency) ---
class GTColors {
  // Base Colors
  static const Color primaryBaseDark = Color(0xFF1A2B27);
  static const Color secondaryBaseLight = Color(0xFFF3F8F5);
  static const Color darkText = Color(0xFF333333);
  static const Color terracotta = Color(0xFFC85C2C);

  // Dynamic Greens
  static const Color lushGreen = Color(0xFF3D8B40); // Primary button
  static const Color radiantGreen = Color(0xFF70C65A); // Accent/Gradient end

  // Functional Accents
  static const Color berryRed = Color(0xFFE7625F); // Alerts/Urgency
  static const Color skyBlue = Color(0xFF79B4B7); // Water/Links
  static const Color sunburstYellow = Color(0xFFFFD700); // Success/Highlight
}
// =========================================================================

class DiagnosisScreen extends StatelessWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Diagnosis 🔎', style: TextStyle(color: GTColors.primaryBaseDark)),
        backgroundColor: GTColors.radiantGreen,
        iconTheme: const IconThemeData(color: GTColors.primaryBaseDark),
      ),
      body: Center(
        child: Text(
          'Camera Interface for Plant ID/Diagnosis is here!',
          style: TextStyle(fontSize: 18, color: GTColors.darkText),
        ),
      ),
    );
  }
}

class CareTaskDetailPage extends StatelessWidget {
  final String plantName;
  final String task;

  const CareTaskDetailPage({
    super.key,
    required this.plantName,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task: $task for $plantName', style: const TextStyle(color: GTColors.primaryBaseDark)),
        backgroundColor: GTColors.radiantGreen,
        iconTheme: const IconThemeData(color: GTColors.primaryBaseDark),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(task.contains('Water') ? Icons.opacity : Icons.spa, size: 50, color: GTColors.lushGreen),
              const SizedBox(height: 20),
              Text(
                'Details for the "$task" task for your $plantName plant.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: GTColors.darkText),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GTColors.lushGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mark as Complete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullTrackerPage extends StatelessWidget {
  const FullTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Full Green Impact 📊', style: TextStyle(color: GTColors.primaryBaseDark)),
        backgroundColor: GTColors.radiantGreen,
        iconTheme: const IconThemeData(color: GTColors.primaryBaseDark),
      ),
      body: Center(
        child: Text(
          'Detailed graphs and statistics on your environmental impact.',
          style: TextStyle(fontSize: 18, color: GTColors.darkText),
        ),
      ),
    );
  }
}

class CommunityHotTopicPage extends StatelessWidget {
  const CommunityHotTopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Hot Topic 🔥', style: TextStyle(color: GTColors.primaryBaseDark)),
        backgroundColor: GTColors.radiantGreen,
        iconTheme: const IconThemeData(color: GTColors.primaryBaseDark),
      ),
      body: Center(
        child: Text(
          'The popular discussion thread about Monstera Deliciosa.',
          style: TextStyle(fontSize: 18, color: GTColors.darkText),
        ),
      ),
    );
  }
}