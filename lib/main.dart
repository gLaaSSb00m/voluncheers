import 'package:flutter/material.dart';
import 'package:voluncheers/screens/onboarding_screen.dart'; // Assuming the file is in the same directory
import 'package:voluncheers/utils/supabase_config.dart';
import 'package:voluncheers/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  
  // Initialize AuthService to start listening to auth states
  AuthService();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner
      home: OnboardingScreen(),
    );
  }
}
