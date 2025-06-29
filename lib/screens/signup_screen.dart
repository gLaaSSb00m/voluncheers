import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/progress_indicator.dart';
import '../services/auth_service.dart';
import 'personal_details_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _checkTerms = false;

  DateTime? _lastSignupAttempt;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Simple email validation - accepts any valid email format
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_checkTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Attempting signup...'); // Debug log
      final response = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      print('Signup response received'); // Debug log

      if (response.user != null && mounted) {
        // Show verification dialog
        if (mounted) {
          _showVerificationDialog(response.user!.email!);
        }
      }
    } catch (e) {
      if (mounted) {
        print('Error in signup screen: $e'); // Debug log
        String errorMessage = 'An error occurred during signup';
        
        if (e.toString().contains('rate_limit')) {
          errorMessage = 'Please wait a few seconds before trying again';
        } else if (e.toString().contains('invalid_email')) {
          errorMessage = 'Please enter a valid email address';
        } else if (e.toString().contains('weak_password')) {
          errorMessage = 'Password must be at least 6 characters';
        } else if (e.toString().contains('email_taken')) {
          errorMessage = 'This email is already registered';
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify Your Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please check your email and click the verification link to continue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Email sent to: $email',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'After verifying your email, click the button below to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  // Attempt to verify and sign in
                  final isVerified = await _authService.verifyAndSignIn(
                    email: _emailController.text.trim(),
                    password: _passwordController.text,
                  );
                  
                  if (mounted) {
                    if (isVerified) {
                      // Clear form after successful verification
                      _nameController.clear();
                      _emailController.clear();
                      _passwordController.clear();
                      setState(() => _checkTerms = false);
                      
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PersonalDetailsScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please verify your email first by clicking the link sent to your email'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error checking verification: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
                      ),
                    )
                  : const Text('I\'ve Verified My Email'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88,
                  child: const ProgressIndicatorWidget(currentStep: 0),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInputField(
                        "Name",
                        _nameController,
                        _nameFocus,
                        Icons.person_outline,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        "Email",
                        _emailController,
                        _emailFocus,
                        Icons.email_outlined,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        "Password",
                        _passwordController,
                        _passwordFocus,
                        Icons.lock_outline,
                        isPassword: true,
                        validator: _validatePassword,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      activeColor: AppColors.darkGreen,
                      value: _checkTerms,
                      onChanged: (val) {
                        setState(() {
                          _checkTerms = val ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "By signing up, you agree to our Terms & Conditions",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              elevation: 8,
              shadowColor: AppColors.darkGreen.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Continue >",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    IconData prefixIcon, {
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    final bool isFocused = focusNode.hasFocus;

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        setState(() {}); // Trigger rebuild for shadow & border.
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: AppColors.golden.withOpacity(0.3),
                    offset: const Offset(0, 8),
                    blurRadius: 16,
                  ),
                ]
              : [],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          cursorColor: Colors.black,
          style: const TextStyle(fontSize: 16, color: AppColors.textColor),
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: Icon(prefixIcon, color: Colors.grey.shade700),
            fillColor: Colors.white,
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.golden, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade300, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
