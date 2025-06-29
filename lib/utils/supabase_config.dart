import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String SUPABASE_URL = 'https://mdspsbczmrzdncopuypi.supabase.co';
  static const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kc3BzYmN6bXJ6ZG5jb3B1eXBpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ0MDQ0NzIsImV4cCI6MjA1OTk4MDQ3Mn0.KTc8DEIdg0aoJHmYA-VqImbiCLgx1EtZOi7GJXjuAtY';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
      debug: true,
    );
  }
} 