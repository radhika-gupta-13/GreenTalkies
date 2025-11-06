import 'package:flutter/material.dart';

// --- DATA MODELS & MOCK DATA ---

class Badge {
  final String name;
  final IconData icon;
  final String description;
  final bool earned;

  Badge({required this.name, required this.icon, required this.description, this.earned = false});
}

class Challenge {
  final String name;
  final String goal;
  final double progress; // 0.0 to 1.0
  final Color progressColor;

  Challenge({required this.name, required this.goal, required this.progress, required this.progressColor});
}

class NotificationItem {
  final String title;
  final String body;
  final String time;
  final String type; // e.g., 'system', 'challenge', 'community'
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case 'challenge':
        return Icons.military_tech_rounded;
      case 'community':
        return Icons.people_rounded;
      case 'tip':
        return Icons.lightbulb_rounded;
      case 'system':
      default:
        return Icons.info_rounded;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'challenge':
        return Colors.green.shade800;
      case 'community':
        return Colors.blue.shade700;
      case 'tip':
        return Colors.orange.shade700;
      case 'system':
      default:
        return Colors.grey.shade600;
    }
  }
}


final List<Badge> mockBadges = [
  Badge(name: 'Compost King', icon: Icons.recycling_rounded, description: 'Started your first compost heap.', earned: true),
  Badge(name: 'Seed Starter', icon: Icons.grass_rounded, description: 'Successfully grown 5 different plants.', earned: true),
  Badge(name: 'Water Saver', icon: Icons.opacity_rounded, description: 'Reduced daily water use by 10%.', earned: false),
];

final List<Challenge> mockChallenges = [
  Challenge(name: 'Meatless Monday', goal: 'Complete 4 Meatless Mondays this month.', progress: 0.75, progressColor: Colors.red.shade700),
  Challenge(name: 'Ditch Plastic Bottles', goal: 'Use a reusable bottle for 30 consecutive days.', progress: 0.5, progressColor: Colors.blue.shade700),
];

final List<NotificationItem> mockNotifications = [
  NotificationItem(
    title: 'Challenge Completed!',
    body: 'You successfully completed the "Meatless Monday" challenge this week. Great work!',
    time: '2 hours ago',
    type: 'challenge',
    isRead: false,
  ),
  NotificationItem(
    title: 'New Eco Tip Available',
    body: 'Did you know switching off your modem at night can save you significant energy? Check it out!',
    time: '5 hours ago',
    type: 'tip',
    isRead: false,
  ),
  NotificationItem(
    title: 'Community Post Trending',
    body: '"Best practices for urban gardening" is trending! Check out the helpful comments.',
    time: 'Yesterday',
    type: 'community',
    isRead: true,
  ),
  NotificationItem(
    title: 'GreenTalkies Update',
    body: 'New badge tiers have been released! Work towards becoming a "Planetary Protector".',
    time: '2 days ago',
    type: 'system',
    isRead: true,
  ),
  NotificationItem(
    title: 'Badge Unlocked: Power Down',
    body: 'Congratulations! You earned the Power Down badge for using energy-efficient bulbs.',
    time: '3 days ago',
    type: 'challenge',
    isRead: true,
  ),
];


// --- MAIN APPLICATION SETUP ---

void main() {
  // Define the primary color for a cohesive GreenTalkies theme (Dark Forest Green)
  final MaterialColor primaryGreen = MaterialColor(
    0xFF1B5E20,
    <int, Color>{
      50: const Color(0xFFE8F5E9), 
      100: const Color(0xFFC8E6C9), 
      200: const Color(0xFFA5D6A7), 
      300: const Color(0xFF81C784), 
      400: const Color(0xFF66BB6A), 
      500: const Color(0xFF4CAF50), 
      600: const Color(0xFF43A047), 
      700: const Color(0xFF388E3C), 
      800: const Color(0xFF2E7D32), 
      900: const Color(0xFF1B5E20), // Darkest shade for theme
    },
  );

  runApp(GreenTalkiesApp(primaryGreen: primaryGreen));
}

class GreenTalkiesApp extends StatelessWidget {
  final MaterialColor primaryGreen;

  const GreenTalkiesApp({super.key, required this.primaryGreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenTalkies Eco Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primaryGreen,
        scaffoldBackgroundColor: const Color(0xFFF0FFF0), // Very light pale green background
        appBarTheme: AppBarTheme(
          backgroundColor: primaryGreen.shade800,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: primaryGreen).copyWith(
          secondary: Colors.lightGreen.shade400, // Accent color
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(), 
    );
  }
}

// -----------------------------------------------------------------------------
// --- WIDGET 1: NotificationsPage (The New Beautiful Page)
// -----------------------------------------------------------------------------

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // In a real app, you would manage the read/unread state here
  // For this example, we use the mock data's initial state.
  final List<NotificationItem> notifications = mockNotifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700),),
        backgroundColor: const Color.fromARGB(255, 60, 162, 65),
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 60, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(height: 10),
                  const Text('All caught up!', style: TextStyle(fontSize: 18, color: Colors.black54)),
                  const Text('No new alerts.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(context, notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : Colors.green.shade50, // Highlight unread
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: item.iconColor,
          size: 30,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
            color: item.isRead ? Colors.black87 : Theme.of(context).primaryColor.shade900,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              item.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: item.isRead ? Colors.grey.shade600 : Colors.black,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.time,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: item.isRead
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          // In a real application, tapping would mark it as read and navigate to the related content.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing details for "${item.title}"')),
          );
        },
      ),
    );
  }
}

extension on Color {
  get shade900 => null;
}

// -----------------------------------------------------------------------------
// --- WIDGET 2: HomeScreen (Updated with Notification Button)
// -----------------------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenTalkies Hub'),
        actions: [
          // NEW: Notification Button
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_rounded, 
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  // Functionality: Open Notifications Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()),
                  );
                },
              ),
              // Unread indicator dot
              if (mockNotifications.any((n) => !n.isRead))
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                )
            ],
          ),
          
          // EXISTING: Badges Button
          IconButton(
            icon: const Icon(
              Icons.military_tech_rounded, // Icon for badges/achievements
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              // Functionality: Open Badges and Challenges
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BCPages()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_rounded, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            const Text(
              'Welcome to GreenTalkies!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Check your notifications and achievements using the icons in the app bar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// --- WIDGET 3: BCPages (Kept for completeness)
// -----------------------------------------------------------------------------

class BCPages extends StatefulWidget {
  const BCPages({super.key});

  @override
  State<BCPages> createState() => _BCPagesState();
}

class _BCPagesState extends State<BCPages> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Greenie Tracker'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Badges', icon: Icon(Icons.star_half_rounded)),
            Tab(text: 'Challenges', icon: Icon(Icons.list_alt_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBadgesGrid(context),
          _buildChallengesList(context),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: mockBadges.length,
      itemBuilder: (context, index) {
        final badge = mockBadges[index];
        return _buildBadgeItem(context, badge);
      },
    );
  }

  Widget _buildBadgeItem(BuildContext context, Badge badge) {
    return Opacity(
      opacity: badge.earned ? 1.0 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          color: badge.earned ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (badge.earned)
              BoxShadow(
                color: Colors.green.shade100,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
          border: Border.all(
            color: badge.earned ? Theme.of(context).colorScheme.secondary : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              badge.icon,
              size: 40,
              color: badge.earned ? Theme.of(context).primaryColor : Colors.grey.shade500,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                badge.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: badge.earned ? Colors.black87 : Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockChallenges.length,
      itemBuilder: (context, index) {
        final challenge = mockChallenges[index];
        return _buildChallengeItem(context, challenge);
      },
    );
  }

  Widget _buildChallengeItem(BuildContext context, Challenge challenge) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.goal,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            
            // Progress Bar
            LinearProgressIndicator(
              value: challenge.progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(challenge.progressColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),

            // Progress Text and Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress: ${(challenge.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: challenge.progressColor,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Action to log progress or view details
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Log Impact', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
