import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication/login.dart';
import 'authentication/sign_up.dart';
import 'authentication/forgot_password.dart';
import 'home_content/home.dart';
import 'home_content/identify_diagnose.dart';
import 'package:greentalkies/bud & basket/providers/cart_provider.dart';
import 'package:greentalkies/bud & basket/providers/wishlist_provider.dart';

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
        ChangeNotifierProvider(create: (_) => CartProvider()),       // Global cart
        ChangeNotifierProvider(create: (_) => WishlistProvider()),   // Global wishlist
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
          '/': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/forgot': (context) => const ForgotPasswordPage(),
          '/home': (context) => const HomeScreen(),
          '/identify': (context) => const IdentifyDiagnosePage(),
        },
      ),
    );
  }
}
