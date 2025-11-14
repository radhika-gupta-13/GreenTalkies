import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greentalkies/colors.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../authentication/login.dart';
import '/backend_config.dart'; 

// ----------------------------
// User Model
// ----------------------------
class User {
  final String uid;
  String displayName;
  String email;
  String? photoUrl;

  User({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['_id'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
    );
  }
}

// ----------------------------
// Profile Page
// ----------------------------
class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  bool isLoading = false;
  bool fetchError = false;
  String? baseUrl;
  File? _newImage;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _setupBaseUrlAndFetchUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ----------------------------
  // Setup backend URL & fetch user
  // ----------------------------
  Future<void> _setupBaseUrlAndFetchUser() async {
    try {
      final ip = await BackendConfig.getServerIp();
      baseUrl = BackendConfig.apiBase(ip);

      // Load locally saved photo first
      final prefs = await SharedPreferences.getInstance();
      String? savedPhoto = prefs.getString('profilePhoto_${widget.userId}');
      if (savedPhoto != null && mounted) {
        setState(() {
          user = User(uid: widget.userId, displayName: '', email: '', photoUrl: savedPhoto);
        });
      }

      await _fetchUser();
    } catch (e) {
      setState(() => fetchError = true);
      print("❌ Error initializing profile page: $e");
    }
  }

  // ----------------------------
  // Fetch user data
  // ----------------------------
  Future<void> _fetchUser() async {
    if (baseUrl == null || widget.userId.isEmpty) {
      setState(() => fetchError = true);
      return;
    }

    setState(() {
      isLoading = true;
      fetchError = false;
    });

    try {
      final url = Uri.parse('$baseUrl/user/${widget.userId}');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final freshUser = User.fromJson(jsonDecode(response.body));

        // Preserve local photo if exists
        final prefs = await SharedPreferences.getInstance();
        String? savedPhoto = prefs.getString('profilePhoto_${widget.userId}');
        if (savedPhoto != null) freshUser.photoUrl = savedPhoto;

        setState(() {
          user = freshUser;
          _nameController.text = user!.displayName;
          _emailController.text = user!.email;
        });
      } else {
        setState(() => fetchError = true);
      }
    } catch (_) {
      setState(() => fetchError = true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ----------------------------
  // Save profile changes
  // ----------------------------
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate() || user == null || baseUrl == null) return;

    setState(() => isLoading = true);

    Map<String, dynamic> updatedData = {};
    if (_nameController.text.trim() != user!.displayName) updatedData['displayName'] = _nameController.text.trim();
    if (_emailController.text.trim() != user!.email) updatedData['email'] = _emailController.text.trim();
    if (_passwordController.text.isNotEmpty) updatedData['password'] = _passwordController.text.trim();

    if (updatedData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No changes were made.')));
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/${user!.uid}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          user!.displayName = data['displayName'] ?? user!.displayName;
          user!.email = data['email'] ?? user!.email;
        });
        _passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
      } else {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Failed to update profile';
        throw Exception(message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ----------------------------
  // Upload profile photo
  // ----------------------------
  Future<void> _uploadPhoto() async {
    if (user == null || baseUrl == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => isLoading = true);
    _newImage = File(pickedFile.path);

    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/user/${user!.uid}/photo'));
      request.files.add(await http.MultipartFile.fromPath('photo', _newImage!.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String? newPhotoUrl = data['photoUrl'];
        if (newPhotoUrl != null && newPhotoUrl.isNotEmpty) {
          newPhotoUrl += newPhotoUrl.contains('?')
              ? '&v=${DateTime.now().millisecondsSinceEpoch}'
              : '?v=${DateTime.now().millisecondsSinceEpoch}';
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profilePhoto_${user!.uid}', newPhotoUrl!);

        setState(() {
          user!.photoUrl = newPhotoUrl;
          _newImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated!')));
      } else {
        throw Exception(data['message'] ?? 'Failed to upload photo');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading photo: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ----------------------------
  // Logout
  // ----------------------------
  Future<void> _logout() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
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
      await http.post(Uri.parse('$baseUrl/auth/logout'));
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  // ----------------------------
  // Build
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    if (fetchError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to fetch profile.', style: TextStyle(fontSize: 18, color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: _fetchUser, icon: const Icon(Icons.refresh), label: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (user == null || (isLoading && _newImage == null)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ImageProvider avatarImage;
    if (_newImage != null) {
      avatarImage = FileImage(_newImage!);
    } else if (user!.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      avatarImage = NetworkImage(user!.photoUrl!);
    } else {
      avatarImage = const AssetImage('assets/default_avatar.png'); // fallback default
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GTColors.lushGreen,
        title: const Text('Profile & Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _uploadPhoto,
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: GTColors.lushGreen,
                            backgroundImage: avatarImage,
                            child: (_newImage == null && (user!.photoUrl == null || user!.photoUrl!.isEmpty))
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user!.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      _SettingsField(controller: _nameController, label: 'Update Username', hint: 'Enter username', icon: Icons.person_outline),
                      _SettingsField(controller: _emailController, label: 'Update Email', hint: 'Enter email', icon: Icons.email_outlined),
                      _SettingsField(controller: _passwordController, label: 'Update Password', hint: 'Enter new password', icon: Icons.lock_outline, isPassword: true),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(onPressed: _saveSettings, icon: const Icon(Icons.save), label: const Text('Save Changes')),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text('Logout'), style: ElevatedButton.styleFrom(backgroundColor: GTColors.berryRed)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// ----------------------------
// Settings Field Widget
// ----------------------------
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
