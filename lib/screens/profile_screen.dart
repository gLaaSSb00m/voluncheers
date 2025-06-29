import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_config.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _supabase = SupabaseConfig.client;
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        
        setState(() {
          _profileData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() => _isLoading = false);
    }
  }

  int _calculateAge(String? dob) {
    if (dob == null) return 0;
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || 
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildInfoCard({
    String? title,
    List<Widget>? children,
    List<_InfoItem>? items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF01311F),
                ),
              ),
            ),
            const Divider(height: 1),
          ],
          if (children != null) ...children,
          if (items != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(item.icon, color: const Color(0xFF01311F)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF01311F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Color(0xFF01311F),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF01311F).withOpacity(0.1),
                    child: _profileData?['avatar_url'] != null
                        ? ClipOval(
                            child: Image.network(
                              _profileData!['avatar_url'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF01311F),
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF01311F),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profileData?['name'] ?? 'Volunteer',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Personal Information
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Contact Information',
              children: [
                _buildInfoRow('Email', _profileData?['email'] ?? 'Not provided'),
                _buildInfoRow('Phone', _profileData?['phone_number'] ?? 'Not provided'),
              ],
            ),
            _buildInfoCard(
              title: 'Personal Information',
              children: [
                _buildInfoRow('Gender', _profileData?['gender'] ?? 'Not provided'),
                if (_profileData?['date_of_birth'] != null) ...[
                  _buildInfoRow(
                    'Age',
                    '${_calculateAge(_profileData!['date_of_birth'])} years',
                  ),
                  _buildInfoRow(
                    'Date of Birth',
                    DateFormat('MMMM d, yyyy').format(DateTime.parse(_profileData!['date_of_birth'])),
                  ),
                ],
              ],
            ),
            // Interests & Skills
            if (_profileData?['interests'] != null && (_profileData?['interests'] as List).isNotEmpty)
              _buildInfoCard(
                title: 'Interests & Skills',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      children: (_profileData!['interests'] as List)
                          .map((interest) => _buildTagChip(interest.toString()))
                          .toList(),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Volunteering History
            const Text(
              'Volunteering History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              items: [
                _InfoItem(
                  icon: Icons.volunteer_activism,
                  label: 'Hours Volunteered',
                  value: '0', // TODO: Implement hours tracking
                ),
                _InfoItem(
                  icon: Icons.event,
                  label: 'Events Attended',
                  value: '0', // TODO: Implement events tracking
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Edit Profile Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement edit profile functionality
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01311F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
} 