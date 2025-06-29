import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_config.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  
  // Store the current signup session
  AuthResponse? _currentSignupSession;
  
  // Regular expression for Bangladesh phone numbers
  static final RegExp _bdPhoneRegex = RegExp(r'^\+?(880|0)?(1[3-9]\d{8})$');

  // Format phone number to international format
  String _formatBangladeshPhone(String phone) {
    // Remove any spaces, dashes or parentheses
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Extract the actual number using regex
    final match = _bdPhoneRegex.firstMatch(phone);
    if (match == null) {
      throw Exception('Invalid Bangladesh phone number format');
    }
    
    // Get the actual 10-digit number (group 2 in our regex)
    final number = match.group(2);
    if (number == null) {
      throw Exception('Failed to parse phone number');
    }
    
    // Return the properly formatted international number
    return '+880$number';
  }

  // Validate Bangladesh phone number
  bool isValidBangladeshPhone(String phone) {
    return _bdPhoneRegex.hasMatch(phone);
  }

  // Send OTP to phone number
  Future<void> sendPhoneVerification(String phone) async {
    try {
      if (!isValidBangladeshPhone(phone)) {
        throw Exception('Invalid Bangladesh phone number');
      }

      final formattedPhone = _formatBangladeshPhone(phone);
      print('Sending OTP to: $formattedPhone'); // Debug log

      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
      );
      
      print('OTP sent successfully'); // Debug log
    } catch (e) {
      print('Phone verification error: $e'); // Debug log
      throw Exception('Failed to send verification code: ${e.toString()}');
    }
  }

  // Verify OTP code
  Future<AuthResponse> verifyPhone(String phone, String otp) async {
    try {
      final formattedPhone = _formatBangladeshPhone(phone);
      print('Verifying OTP for: $formattedPhone'); // Debug log

      // First, try to verify the OTP
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: formattedPhone,
        token: otp,
      );

      print('Verification response:');
      print('- Session exists: ${response.session != null}');
      print('- User exists: ${response.user != null}');
      print('- User phone: ${response.user?.phone}');

      // If we don't have a session or user, the verification failed
      if (response.session == null || response.user == null) {
        throw Exception('Verification failed - invalid code');
      }

      // At this point, if we have a session and user, the verification was successful
      print('Phone verification successful');
      return response;

    } catch (e) {
      print('OTP verification error: $e'); // Debug log
      
      // Handle specific error cases
      if (e.toString().contains('Invalid token')) {
        throw Exception('Invalid verification code');
      } else if (e.toString().contains('Token has expired')) {
        throw Exception('Code has expired');
      } else {
        throw Exception('Failed to verify code: ${e.toString()}');
      }
    }
  }

  // Update user's phone number in profile
  Future<void> updatePhoneInProfile(String userId, String phone) async {
    try {
      final formattedPhone = _formatBangladeshPhone(phone);
      
      // First update the user metadata
      await _supabase.auth.updateUser(UserAttributes(
        phone: formattedPhone,
      ));

      // Then update the profile if you have a profiles table
      try {
        await _supabase
            .from('profiles')
            .update({
              'phone_number': formattedPhone, // Changed from 'phone' to 'phone_number'
              'phone_verified': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      } catch (profileError) {
        // If profiles table update fails, log it but don't throw
        print('Profile update warning: $profileError');
        // The verification is still successful even if profile update fails
      }
      
      print('Phone verification status updated'); // Debug log
    } catch (e) {
      print('Update phone error: $e'); // Debug log
      throw Exception('Failed to update phone: ${e.toString()}');
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('Starting signup process...'); // Debug log
      
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'pending_profile': true,
        },
      );

      print('Signup response: ${res.user != null ? 'Success' : 'Failed'}'); // Debug log
      
      if (res.user == null) {
        throw Exception('User creation failed');
      }

      // Store the signup session
      _currentSignupSession = res;
      
      return res;
    } catch (e) {
      print('Signup error: $e'); // Debug log
      throw Exception(e.toString());
    }
  }

  Future<bool> verifyAndSignIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting verification and sign in...'); // Debug log
      
      // First, try to sign in
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      print('Sign in response:');
      print('- User: ${res.user?.email}');
      print('- Session: ${res.session != null}');
      
      if (res.user == null || res.session == null) {
        print('Sign in failed - no user or session'); // Debug log
        return false;
      }

      // Get fresh user data
      final userResponse = await _supabase.auth.getUser();
      final user = userResponse.user;
      
      print('User verification check:');
      print('- Email: ${user?.email}');
      print('- Email verified: ${user?.emailConfirmedAt != null}');
      print('- Confirmed at: ${user?.emailConfirmedAt}');
      
      // Check if email is confirmed by looking at emailConfirmedAt
      final bool isVerified = user?.emailConfirmedAt != null;
      print('Verification status: ${isVerified ? 'Verified' : 'Not verified'}');
      
      return isVerified;
    } catch (e) {
      print('Verification check error: $e'); // Debug log
      return false;
    }
  }

  Future<AuthResponse?> getCurrentSession() async {
    final session = _supabase.auth.currentSession;
    return session != null ? _currentSignupSession : null;
  }

  Future<void> signOut() async {
    _currentSignupSession = null;
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      print('Attempting to update profile for user: $userId'); // Debug log
      print('Profile data: $data'); // Debug log

      // First try to insert the profile
      try {
        await _supabase
            .from('profiles')
            .insert({
              'id': userId,
              ...data,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
        print('Profile created successfully'); // Debug log
      } catch (insertError) {
        print('Insert error (might be duplicate): $insertError'); // Debug log
        
        // If insert fails, try to update
        try {
          await _supabase
              .from('profiles')
              .update({
                ...data,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', userId);
          print('Profile updated successfully'); // Debug log
        } catch (updateError) {
          print('Update error: $updateError'); // Debug log
          throw Exception('Failed to update profile: ${updateError.toString()}');
        }
      }
    } catch (e) {
      print('Profile update error: $e'); // Debug log
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  Future<void> createProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      await _supabase
          .from('profiles')
          .insert({
            'id': userId,
            'name': name,
            'email': email,
          });
    } catch (e) {
      print('Profile creation error: $e'); // Debug log
      throw Exception('Failed to create profile');
    }
  }

  Future<void> createVerifiedUserProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      await _supabase
          .from('profiles')
          .insert({
            'id': userId,
            'name': name,
            'email': email,
            'phone_number': phone,
            'phone_verified': true,
            'email_verified': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Profile creation error: $e'); // Debug log
      throw Exception('Failed to create profile');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      print('Starting password reset for email: $email'); // Debug log

      // Check if the user exists in the profiles table
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('email', email)
          .single();
      
      print('Profile check response: $response');

      print('Sending password reset email...'); // Debug log
      
      // Send password reset email using Supabase's built-in method
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'voluncheers://reset-password',
      );
      
      print('Password reset email sent successfully'); // Debug log
    } catch (e) {
      print('Password reset error: $e'); // Debug log
      if (e.toString().contains('duplicate key')) {
        throw Exception('This email is already registered');
      } else if (e.toString().contains('invalid email')) {
        throw Exception('Please enter a valid email address');
      } else {
        throw Exception('Failed to send password reset email: ${e.toString()}');
      }
    }
  }
} 