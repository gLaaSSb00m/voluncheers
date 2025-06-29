import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/progress_indicator.dart';
import 'signup_success_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String email;

  const ConfirmationScreen({
    Key? key,
    required this.phoneNumber,
    required this.name,
    required this.email,
  }) : super(key: key);

  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Clear the code field
  void _clearCode() {
    _codeController.clear();
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _confirmCode() async {
    final code = _codeController.text.trim();
    
    // Validate code format
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the verification code';
      });
      return;
    }

    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = AuthService();
    try {
      print('Attempting to verify code: $code for phone: ${widget.phoneNumber}');
      final response = await authService.verifyPhone(widget.phoneNumber, code);
      
      if (!mounted) return;

      // If we get here, verification was successful
      try {
        // First update the phone number in user metadata
        await authService.updatePhoneInProfile(response.user!.id, widget.phoneNumber);
        
        // Then create the complete verified user profile
        await authService.createVerifiedUserProfile(
          userId: response.user!.id,
          name: widget.name,
          email: widget.email,
          phone: widget.phoneNumber,
        );
      } catch (profileError) {
        print('Warning - profile creation failed: $profileError');
        // Even if profile creation fails, we'll continue as the verification was successful
      }

      if (!mounted) return;

      // Show success message and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to the success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupSuccessScreen()),
      );

    } catch (e) {
      if (!mounted) return;
      print('Verification error: $e');
      
      // Clear the code field on error
      _clearCode();
      
      setState(() {
        if (e.toString().contains('invalid')) {
          _errorMessage = 'Invalid verification code. Please try again.';
        } else if (e.toString().contains('expired')) {
          _errorMessage = 'Code has expired. Please request a new code.';
        } else {
          _errorMessage = 'Verification failed. Please try again.';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify Your Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.88,
                child: const ProgressIndicatorWidget(currentStep: 2),
              ),
              const SizedBox(height: 40),
              const Text(
                'Verification code sent to your number:',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.5),
                    fontSize: 24,
                    letterSpacing: 8,
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300] ?? Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300] ?? Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.darkGreen, width: 2.0),
                  ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          try {
                            setState(() => _isLoading = true);
                            final authService = AuthService();
                            await authService.sendPhoneVerification(widget.phoneNumber);
                            
                            // Clear the current code when requesting a new one
                            _clearCode();
                            
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('New verification code sent!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to send new code. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(color: AppColors.darkGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () {
                    // Skip verification and proceed to success screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupSuccessScreen()),
                    );
                  },
                  child: const Text(
                    'I don\'t have my number with me now',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
