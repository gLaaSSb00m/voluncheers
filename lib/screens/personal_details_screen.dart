import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../utils/progress_indicator.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'confirmation_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _dateController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  final Set<String> _selectedInterests = {};
  bool _isLoading = false;

  final List<Map<String, dynamic>> _interestOptions = [
    {'label': 'Training', 'icon': Icons.school},
    {'label': 'Event Planning', 'icon': Icons.event},
    {'label': 'Fundraising', 'icon': Icons.monetization_on},
    {'label': 'Community Outreach', 'icon': Icons.people},
    {'label': 'Environmental', 'icon': Icons.eco},
    {'label': 'Crisis Support', 'icon': Icons.support},
    {'label': 'Day Care', 'icon': Icons.child_care},
    {'label': 'Disaster Response', 'icon': Icons.emergency},
    {'label': 'Mentoring', 'icon': Icons.psychology},
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.darkGreen,
            colorScheme: const ColorScheme.light(primary: AppColors.darkGreen),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    final authService = AuthService();
    final currentContext = context;

    // Validate phone number using AuthService's validator
    if (!authService.isValidBangladeshPhone(_phoneController.text)) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Bangladeshi phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate date of birth
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate gender
    if (_selectedGender == null) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate interests
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one interest'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = authService.currentUser;
      final phone = _phoneController.text;

      if (user != null) {
        print('Starting profile update for user: ${user.id}'); // Debug log
        
        // Prepare profile data
        final profileData = {
          'phone_number': phone,
          'date_of_birth': _dateController.text,
          'gender': _selectedGender,
          'interests': _selectedInterests.toList(),
          'phone_verified': false,
          'name': user.userMetadata?['name'] ?? '',
          'email': user.email,
        };

        print('Profile data prepared: $profileData'); // Debug log

        // First update the profile
        await authService.updateProfile(
          userId: user.id,
          data: profileData,
        );

        print('Profile updated successfully, sending OTP...'); // Debug log

        // Send OTP
        await authService.sendPhoneVerification(phone);

        if (currentContext.mounted) {
          print('Navigating to confirmation screen...'); // Debug log
          // Navigate to confirmation screen with all required data
          Navigator.push(
            currentContext,
            MaterialPageRoute(
              builder: (context) => ConfirmationScreen(
                phoneNumber: phone,
                name: user.userMetadata?['name'] ?? '',
                email: user.email ?? '',
              ),
            ),
          );
        }
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      print('Error in _handleSubmit: $e'); // Debug log
      if (currentContext.mounted) {
        String errorMessage = 'Failed to update profile';
        
        if (e.toString().contains('No authenticated user')) {
          errorMessage = 'Please sign in again and try updating your profile';
        } else if (e.toString().contains('duplicate key')) {
          errorMessage = 'This phone number is already registered';
        } else if (e.toString().contains('invalid input syntax')) {
          errorMessage = 'Invalid data format. Please check your inputs';
        } else if (e.toString().contains('Failed to update profile')) {
          errorMessage = 'Could not save your profile. Please try again.';
        }

        ScaffoldMessenger.of(currentContext).showSnackBar(
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
                'Personal Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.88,
                child: const ProgressIndicatorWidget(currentStep: 1),
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.darkGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Date of Birth
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                      hintText: 'Date of Birth',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                  hintText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 24),
              // Gender Selection
              Row(
                children: [
                  _buildGenderOption('Male', Icons.male),
                  const SizedBox(width: 16),
                  _buildGenderOption('Female', Icons.female),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Your interests...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a few and let everyone know what you are interested to work on',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interestOptions.map((interest) => 
                  _buildInterestChip(
                    interest['label'], 
                    interest['icon'],
                  ),
                ).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildGenderOption(String gender, IconData icon) {
    final bool isSelected = _selectedGender == gender;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.darkGreen : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.darkGreen.withOpacity(0.1) : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.darkGreen : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                gender,
                style: TextStyle(
                  color: isSelected ? AppColors.darkGreen : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestChip(String label, IconData icon) {
    final bool isSelected = _selectedInterests.contains(label);
    
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.darkGreen,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.darkGreen : Colors.grey,
      ),
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _selectedInterests.add(label);
          } else {
            _selectedInterests.remove(label);
          }
        });
      },
    );
  }
} 