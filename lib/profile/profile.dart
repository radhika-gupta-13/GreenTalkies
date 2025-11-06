import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:async';

// ------------------------------------------------
// 🌱 User Model
// ------------------------------------------------
class User {
  final String uid;
  String displayName;
  String email;

  User({required this.uid, required this.displayName, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['_id'],
      displayName: json['displayName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {"displayName": displayName, "email": email};
}

// ------------------------------------------------
// ⚙️ Profile Page (Dynamic IP + Network Detection)
// ------------------------------------------------
class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  bool _isLoading = false;
  String? baseUrl;

  Timer? _ipPollTimer;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _setupNetworkListener();
  }

  @override
  void dispose() {
    _ipPollTimer?.cancel();
    super.dispose();
  }

  // ------------------------------------------------
  // 🌐 Setup network listener (periodic Wifi IP polling)
  // ------------------------------------------------
  void _setupNetworkListener() async {
    final info = NetworkInfo();

    // Initial IP fetch
    String? wifiIP = await info.getWifiIP();
    if (wifiIP != null) {
      baseUrl = "http://$wifiIP:4000";
      _fetchUser();
    }

    // Periodic poll to detect IP changes (replaces connectivity_plus dependency)
    _ipPollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      String? newIP = await info.getWifiIP();
      if (newIP != null && "http://$newIP:4000" != baseUrl) {
        if (mounted) {
          setState(() {
            baseUrl = "http://$newIP:4000";
          });
          _fetchUser(); // Refetch user on Wi-Fi IP change
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Network changed, updated backend IP: $newIP'),
            ),
          );
        }
      }
    });
  }

  // ------------------------------------------------
  // 🌱 Fetch user
  // ------------------------------------------------
  Future<void> _fetchUser() async {
    if (baseUrl == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/${widget.userId}'),
      );
      if (response.statusCode == 200) {
        user = User.fromJson(json.decode(response.body));
        _nameController.text = user!.displayName;
        _emailController.text = user!.email;
        setState(() {});
      } else {
        throw Exception('Failed to fetch user');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching user: $e')));
      }
    }
  }

  // ------------------------------------------------
  // 🌱 Save profile changes
  // ------------------------------------------------
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate() || user == null || baseUrl == null)
      return;

    setState(() => _isLoading = true);

    Map<String, dynamic> updatedData = {};
    if (_nameController.text.trim() != user!.displayName)
      updatedData['displayName'] = _nameController.text.trim();
    if (_emailController.text.trim() != user!.email)
      updatedData['email'] = _emailController.text.trim();
    if (_passwordController.text.isNotEmpty)
      updatedData['password'] = _passwordController.text.trim();

    if (updatedData.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes were made.')));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/${user!.uid}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        if (updatedData.containsKey('displayName'))
          user!.displayName = updatedData['displayName'];
        if (updatedData.containsKey('email'))
          user!.email = updatedData['email'];
        _passwordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------
  // 🌱 Logout
  // ------------------------------------------------
  Future<void> _logout() async {
    if (baseUrl == null) return;

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GTColors.berryRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.post(Uri.parse('$baseUrl/auth/logout'));
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully logged out!')),
          );
          Navigator.pop(context); // go back to home/login
        }
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTColors.lushGreen,
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: GTColors.lushGreen,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user!.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(user!.email),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _SettingsField(
                    controller: _nameController,
                    label: 'Update Username',
                    hint: 'Enter username',
                    icon: Icons.person_outline,
                  ),
                  _SettingsField(
                    controller: _emailController,
                    label: 'Update Email',
                    hint: 'Enter email',
                    icon: Icons.email_outlined,
                  ),
                  _SettingsField(
                    controller: _passwordController,
                    label: 'Update Password',
                    hint: 'Enter new password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveSettings,
                      icon: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GTColors.berryRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------
// Reusable Settings Field
// ------------------------------------------------
class _SettingsField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;

  const _SettingsField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
