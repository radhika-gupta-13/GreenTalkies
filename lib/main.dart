import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'authentication/login.dart';
import 'authentication/sign_up.dart';
import 'authentication/forgot_password.dart';
import 'home_content/home.dart';
import 'home_content/identify_diagnose.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: "details.env");

  runApp(const GreenTalkiesApp());
}

class GreenTalkiesApp extends StatelessWidget {
  const GreenTalkiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenTalkies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFFFFCEE),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomeScreen(),
        '/identify': (context) => const IdentifyDiagnosePage(),
      },
    );
  }
}
