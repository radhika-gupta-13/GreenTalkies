import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication/login.dart';
import 'authentication/sign_up.dart';
import 'authentication/forgot_password.dart';
import 'home_content/home.dart';
import 'home_content/identify_diagnose.dart';
import 'package:greentalkies/bud & basket/providers/cart_provider.dart';
import 'package:greentalkies/bud & basket/providers/wishlist_provider.dart';
import 'colors.dart'; // GTColors

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GreenTalkiesApp());
}

class GreenTalkiesApp extends StatelessWidget {
  const GreenTalkiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        title: 'GreenTalkies',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFFFFCEE),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/forgot': (context) => const ForgotPasswordPage(),
          '/home': (context) => const HomeScreen(),
          '/identify': (context) => const IdentifyDiagnosePage(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  void _navigateNext() async {
    // Optional: preload data here if needed
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GTColors.lushGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.eco, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'GreenTalkies',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
