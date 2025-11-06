import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';

// --- Challenge Data Model ---
class Challenge {
  final String title;
  final String description;
  double progress; // State managed by the parent widget
  Challenge({required this.title, required this.description, this.progress = 0.0});
}

// --- Main Stateful Widget ---
class BadgesChallengesPage extends StatefulWidget {
  const BadgesChallengesPage({super.key});

  @override
  State<BadgesChallengesPage> createState() => _BadgesChallengesPageState();
}

class _BadgesChallengesPageState extends State<BadgesChallengesPage> {
  // Initial list of challenges, now stored as mutable state.
  final List<Challenge> _challenges = [
    Challenge(
      title: 'The Propagator',
      description: 'Successfully propagate 5 new plants.',
      progress: 0.6,
    ),
    Challenge(
      title: 'The Great Repot',
      description: 'Repot 3 plants this month.',
      progress: 0.2,
    ),
    Challenge(
      title: 'Water Master',
      description: 'Track hydration for 7 consecutive days.',
      progress: 0.9,
    ),
  ];

  // Function to update the progress of a specific challenge
  void _updateChallengeProgress(int index) {
    setState(() {
      double currentProgress = _challenges[index].progress;
      if (currentProgress < 1.0) {
        // Increase progress by 20% (0.2) until 1.0 (100%) is reached.
        _challenges[index].progress = (currentProgress + 0.2).clamp(0.0, 1.0);
      }
      // If completed, maybe show a toast or a different status later.
      if (_challenges[index].progress == 1.0) {
        // In a real app, you would unlock a badge here.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challenge "${_challenges[index].title}" Completed!'),
            backgroundColor: GTColors.lushGreen,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTColors.secondaryBaseLight,
      appBar: AppBar(
        title: const Text(
          'Badges & Challenges',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: GTColors.primaryBaseDark,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 162, 65),
        iconTheme: const IconThemeData(color: GTColors.primaryBaseDark),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Achievements',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GTColors.lushGreen,
              ),
            ),
            const SizedBox(height: 15),
            // Example Badge Grid
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const <Widget>[
                BadgeItem(
                  icon: Icons.water_drop_rounded, 
                  title: 'Hydration Hero', 
                  isEarned: true, 
                  color: GTColors.skyBlue,
                ),
                BadgeItem(
                  icon: Icons.spa_rounded, 
                  title: 'First Bloom', 
                  isEarned: true, 
                  color: GTColors.radiantGreen,
                ),
                BadgeItem(
                  icon: Icons.forest_rounded, 
                  title: 'Grove Pioneer', 
                  isEarned: false, 
                  color: GTColors.darkText,
                ),
                BadgeItem(
                  icon: Icons.star_rounded, 
                  title: '5 Star Grower', 
                  isEarned: true, 
                  color: GTColors.lushGreen,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Challenges Section
            const Text(
              'Active Challenges',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GTColors.lushGreen,
              ),
            ),
            const SizedBox(height: 15),
            // Map the state challenges to ChallengeCard widgets
            ..._challenges.asMap().entries.map((entry) {
              final index = entry.key;
              final challenge = entry.value;
              return ChallengeCard(
                title: challenge.title,
                progress: challenge.progress,
                description: challenge.description,
                // Pass the update function with the specific index
                onUpdate: () => _updateChallengeProgress(index),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// --- Badge Item Widget (Unchanged) ---
class BadgeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isEarned;
  final Color color;

  const BadgeItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isEarned,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isEarned ? color.withOpacity(0.1) : GTColors.darkText.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: isEarned ? color : GTColors.darkText.withOpacity(0.3), 
              width: isEarned ? 2 : 1,
            ),
          ),
          child: Icon(
            icon,
            size: 35,
            color: isEarned ? color : GTColors.darkText.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
            color: isEarned ? GTColors.darkText : GTColors.darkText.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// --- Challenge Card Widget (Modified to include update button) ---
class ChallengeCard extends StatelessWidget {
  final String title;
  final double progress;
  final String description;
  final VoidCallback onUpdate; // New callback function

  const ChallengeCard({
    super.key,
    required this.title,
    required this.progress,
    required this.description,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = progress >= 1.0;
    
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // Change color if completed
                color: isCompleted ? GTColors.lushGreen : GTColors.primaryBaseDark,
                decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: GTColors.lushGreen,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: GTColors.darkText,
              ),
            ),
            const SizedBox(height: 10),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: GTColors.secondaryBaseLight,
              // Use a different color if completed
              color: isCompleted ? GTColors.radiantGreen : GTColors.lushGreen,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Progress Text
                Text(
                  isCompleted ? 'Completed!' : '${(progress * 100).toInt()}% Complete',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? GTColors.lushGreen : GTColors.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                // Update Button
                SizedBox(
                  height: 30,
                  child: ElevatedButton.icon(
                    onPressed: isCompleted ? null : onUpdate, // Disable if completed
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Update Progress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? GTColors.lightGray : GTColors.lushGreen,
                      foregroundColor: isCompleted ? GTColors.darkText.withOpacity(0.6) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
