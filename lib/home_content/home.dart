import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart' as colors;
import 'schedule_task_page.dart'; // ScheduleTaskAutoOpenPage
import 'greenie.dart' as greenie;
import 'badges.dart';
import 'package:greentalkies/home_content/models.dart'; // PlantTask
import 'notifications.dart' as notif;
import 'identify_diagnose.dart';
import 'package:greentalkies/myplants/my_plants.dart';
import 'package:greentalkies/grove/grove.dart';
import 'package:greentalkies/bud & basket/basket.dart';
import 'package:greentalkies/profile/profile.dart';
import 'care_card.dart'; // CareReminderCard
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:greentalkies/config.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:network_info_plus/network_info_plus.dart';

// Logged-in user ID
String? loggedInUserId;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<PlantTask> _careTasks = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String? _backendIp;
  String _userName = '';
  String? _userId;

  // Impact metrics
  int _plantsPlanted = 0;
  double _co2Absorbed = 0.0;
  int _communityPosts = 0;

  final List<Color> _taskCardColors = [
    colors.GTColors.skyBlue,
    colors.GTColors.berryRed,
    colors.GTColors.radiantGreen,
    colors.GTColors.sunshineYellow,
    colors.GTColors.mintGreen,
  ];

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _setBackendIp();
    await _loadUserId();

    if (_userId != null) {
      await _fetchTasks();
      await _fetchImpactMetrics();
    }
  }

  Future<void> _setBackendIp() async {
    if (kIsWeb) {
      _backendIp = 'http://localhost:4000';
    } else {
      final info = NetworkInfo();
      String? wifiIp = await info.getWifiIP();
      _backendIp = wifiIp != null
          ? 'http://$wifiIp:4000'
          : 'http://10.0.2.2:4000';
    }
    print("✅ Backend IP: $_backendIp");
    setState(() {});
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    loggedInUserId = _userId;

    if (_userId != null) await _fetchUserName(_userId!);
    setState(() {});
  }

  Future<void> _fetchUserName(String userId) async {
    try {
      if (_backendIp == null) return;
      final url = Uri.parse('$_backendIp/user/$userId');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userName = data['displayName'] ?? 'GreenTalkies User';
        });
      } else {
        setState(() {
          _userName = 'GreenTalkies User';
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch user name: $e');
      setState(() {
        _userName = 'GreenTalkies User';
      });
    }
  }

  // -----------------------------
  // Task Management
  // -----------------------------
  Future<void> _fetchTasks() async {
    if (_backendIp == null || _userId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url = Uri.parse('$_backendIp/tasks/$_userId');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<PlantTask> fetchedTasks =
            data.map((e) => PlantTask.fromJson(e)).toList();

        setState(() {
          _careTasks = fetchedTasks;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch tasks';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching tasks: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchImpactMetrics() async {
    if (_backendIp == null || _userId == null) return;

    try {
      final url = Uri.parse('$_backendIp/user/$_userId/impact');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _plantsPlanted = data['plantsPlanted'] ?? 0;
          _co2Absorbed = (data['co2Absorbed'] ?? 0.0).toDouble();
          _communityPosts = data['communityPosts'] ?? 0;
        });
      } else {
        print(
            '❌ Failed to fetch impact metrics, status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching impact metrics: $e');
    }
  }

  // -----------------------------
  // Navigation
  // -----------------------------
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openScheduleTaskPage() {
    if (_backendIp == null || _userId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ScheduleTaskAutoOpenPage(backendUrl: _backendIp!, userId: _userId!),
      ),
    ).then((_) async {
      await _fetchTasks();
      await _fetchImpactMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> _widgetOptions = [
      _HomeContent(
        userName: _userName,
        careTasks: _careTasks,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onTaskCompleted: (task) {}, // implement as needed
        onTaskSnoozed: (task) {}, // implement as needed
        onTaskAdded: (task) {}, // implement as needed
        onRefresh: () async {
          await _fetchTasks();
          await _fetchImpactMetrics();
        },
        userId: _userId!,
        backendUrl: _backendIp ?? '',
        taskCardColors: _taskCardColors,
        plantsPlanted: _plantsPlanted,
        co2Absorbed: _co2Absorbed,
        communityPosts: _communityPosts,
      ),
      MyPlantsScreen(userId: _userId!),
      GroveScreen(userId: _userId!, username: _userName),
      BudBasketScreen(userId: _userId!),
      ProfilePage(userId: _userId!),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colors.GTColors.secondaryBaseLight,
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text(
                'GreenTalkies',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              toolbarHeight: 80,
              backgroundColor: colors.GTColors.lushGreen,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.military_tech,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BadgesChallengesPage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => greenie.GreeniePage()),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_sharp,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => notif.NotificationsPage(),
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: GreenTalkiesBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _openScheduleTaskPage,
              backgroundColor: colors.GTColors.radiantGreen,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// -----------------------------
// Home Content Widget
// -----------------------------
class _HomeContent extends StatelessWidget {
  final String userName;
  final List<PlantTask> careTasks;
  final Function(PlantTask) onTaskCompleted;
  final Function(PlantTask) onTaskSnoozed;
  final Function(PlantTask) onTaskAdded;
  final bool isLoading;
  final String errorMessage;
  final Function() onRefresh;
  final String userId;
  final String backendUrl;
  final List<Color> taskCardColors;

  final int plantsPlanted;
  final double co2Absorbed;
  final int communityPosts;

  const _HomeContent({
    required this.userName,
    required this.careTasks,
    required this.onTaskCompleted,
    required this.onTaskSnoozed,
    required this.onTaskAdded,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.userId,
    required this.backendUrl,
    required this.taskCardColors,
    required this.plantsPlanted,
    required this.co2Absorbed,
    required this.communityPosts,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await onRefresh(),
      color: colors.GTColors.lushGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Hello, ${userName.isNotEmpty ? userName : 'there'}!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.GTColors.primaryBaseDark,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Welcome back to GreenTalkies 🌿',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Identify / Diagnose button
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IdentifyDiagnosePage(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Identify / Diagnose',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Care Tasks
            Text(
              'Your Care Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.GTColors.primaryBaseDark,
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Center(child: Text(errorMessage))
            else if (careTasks.isEmpty)
              const Center(
                child: Text(
                  'No tasks for today! 🌱',
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: careTasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final task = entry.value;
                    final color = taskCardColors[index % taskCardColors.length];
                    return CareReminderCard(
                      taskData: task,
                      cardColor: color,
                      onCompleted: (t) => onTaskCompleted(t),
                      onSnoozed: (t) => onTaskSnoozed(t),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 30),

            // Impact Metrics
            Text(
              'Your Green Impact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.GTColors.primaryBaseDark,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ImpactMetric(
                  value: plantsPlanted.toString(),
                  label: 'Plants Planted',
                  color: colors.GTColors.radiantGreen,
                  icon: Icons.local_florist,
                ),
                ImpactMetric(
                  value: co2Absorbed.toStringAsFixed(1) + ' kg',
                  label: 'CO₂ Absorbed',
                  color: colors.GTColors.skyBlue,
                  icon: Icons.cloud,
                ),
                ImpactMetric(
                  value: communityPosts.toString(),
                  label: 'Posts in Grove',
                  color: colors.GTColors.berryRed,
                  icon: Icons.forum,
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

// Impact Metric Widget
class ImpactMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const ImpactMetric({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

// Bottom Navigation
class GreenTalkiesBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const GreenTalkiesBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: colors.GTColors.lushGreen,
      unselectedItemColor: Colors.black54,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_florist),
          label: 'My Plants',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.nature), label: 'Grove'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_rounded),
          label: 'Bud & Basket',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
