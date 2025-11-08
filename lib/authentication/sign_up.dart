import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:greentalkies/config.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:network_info_plus/network_info_plus.dart'; // for local IP
import '../home_content/home.dart'; // Import HomeScreen

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final String backendUrl = RuntimeConfig().backendUrl;

  bool _isLoading = false;
  String? _backendIp;

  // Error + availability messages
  String? nameError;
  String? emailError;
  String? passwordError;
  String? nameAvailability; // Available /  Taken

  // Password strength
  double passwordStrength = 0;
  String passwordStrengthLabel = '';
  bool _obscurePassword = true;

  Timer? _debounce; // For debounced username check

  @override
  void initState() {
    super.initState();
    _setBackendIp();

    passwordController.addListener(() {
      _checkPasswordStrength(passwordController.text);
    });

    nameController.addListener(() {
      _onUsernameChanged(nameController.text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _setBackendIp() async {
    if (kIsWeb) {
      _backendIp = 'http://localhost:4000';
    } else {
      final info = NetworkInfo();
      String? wifiIp = await info.getWifiIP();
      _backendIp = wifiIp != null ? 'http://$wifiIp:4000' : 'http://10.0.2.2:4000';
    }
    setState(() {});
  }

  void _onUsernameChanged(String username) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (username.isNotEmpty) {
        _checkUsernameAvailability(username);
      } else {
        setState(() {
          nameAvailability = null;
          nameError = null;
        });
      }
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (_backendIp == null) return;

    try {
      final url = Uri.parse('$_backendIp/check-username/$username');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        bool available = result['available'];
        setState(() {
          if (available) {
            nameAvailability = "✅ Username available";
            nameError = null;
          } else {
            nameAvailability = "❌ Username already taken";
            nameError = "Username already exists";
          }
        });
      }
    } catch (e) {}
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.3;
    if (RegExp(r'(?=.*[A-Z])').hasMatch(password)) strength += 0.2;
    if (RegExp(r'(?=.*[0-9])').hasMatch(password)) strength += 0.2;
    if (RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password)) strength += 0.3;

    String label = '';
    if (strength < 0.3) label = 'Weak';
    else if (strength < 0.7) label = 'Medium';
    else label = 'Strong';

    setState(() {
      passwordStrength = strength;
      passwordStrengthLabel = label;
    });
  }

  bool _validateInputs(String name, String email, String password) {
    bool isValid = true;
    setState(() {
      nameError = null;
      emailError = null;
      passwordError = null;

      if (name.isEmpty) {
        nameError = "Full name is required";
        isValid = false;
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (email.isEmpty) {
        emailError = "Email is required";
        isValid = false;
      } else if (!emailRegex.hasMatch(email)) {
        emailError = "Enter a valid email";
        isValid = false;
      }

      if (password.isEmpty) {
        passwordError = "Password is required";
        isValid = false;
      } else if (password.length < 6) {
        passwordError = "Password must be at least 6 characters";
        isValid = false;
      }

      if (nameError == null && nameAvailability == "❌ Username already taken") {
        nameError = "Username already exists";
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> signupUser(
      BuildContext context, String name, String email, String password) async {
    if (_backendIp == null) return;

    if (!_validateInputs(name, email, password)) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('$_backendIp/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'displayName': name,
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful!")),
        );

        // Navigate to HomeScreen and remove previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        final message = responseBody['message'] ?? "Signup failed.";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Signup failed: $error")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStrengthColor() {
    if (passwordStrength < 0.3) return Colors.red;
    if (passwordStrength < 0.7) return Colors.orange;
    return Colors.green;
  }

  void _continueWithoutSignup() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCEE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3C5C2B), Color(0xFF4C8C45)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(60)),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 30, top: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.eco_outlined, color: Colors.white, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Create your GreenTalkies account',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Username
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        labelText: 'Username',
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: nameError,
                      ),
                    ),
                    if (nameAvailability != null && nameError == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            nameAvailability!,
                            style: TextStyle(
                              color: nameAvailability!.contains('✅')
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Email
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        labelText: 'Email',
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: emailError,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: 'Password',
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Password strength meter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: (passwordStrength * 100).toInt(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                height: 6,
                                color: _getStrengthColor(),
                              ),
                            ),
                            Expanded(
                              flex: 100 - (passwordStrength * 100).toInt(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                height: 6,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: _getStrengthColor(),
                            fontWeight: FontWeight.bold,
                          ),
                          child: Text(passwordStrengthLabel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                final name = nameController.text.trim();
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();
                                signupUser(context, name, email, password);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC85C2C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: Color(0xFF4C8C45),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Continue without signing up
                    TextButton(
                      onPressed: _continueWithoutSignup,
                      child: const Text(
                        "Continue without signing up",
                        style: TextStyle(
                          color: Color(0xFF3C5C2B),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
