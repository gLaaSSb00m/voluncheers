import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_config.dart';
import 'package:intl/intl.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../widgets/custom_bottom_nav.dart';
import '../screens/opportunity_details_screen.dart';
import 'favorites_screen.dart';
import '../utils/constants.dart';
import 'profile_screen.dart';
import './chat_screen.dart';
//import 'package:voluncheers/widgets/custom_bottom_nav.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient _supabase = SupabaseConfig.client;
  List<Map<String, dynamic>> _opportunities = [];
  bool _isLoading = true;
  String? _userName;
  List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine = MatchEngine(swipeItems: []);
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchOpportunities();
  }

  Future<void> _fetchUserName() async {
    setState(() {
      _userName = 'Volunteer';
    });
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final meta = user.userMetadata;
        // Try to get name from metadata
        String? firstName = meta?['first_name'] ?? meta?['name'];
        String? lastName = meta?['last_name'];
        
        // If we have both first and last name, use them
        if (firstName != null && lastName != null && firstName.isNotEmpty && lastName.isNotEmpty) {
          _userName = '$firstName $lastName';
        }
        // If we only have first name
        else if (firstName != null && firstName.isNotEmpty) {
          _userName = firstName;
        }
        // If we only have last name
        else if (lastName != null && lastName.isNotEmpty) {
          _userName = lastName;
        }
        // If no name in metadata, try to get from email
        else if (user.email != null) {
          _userName = user.email!.split('@')[0];
        }

        // Fetch additional user data from profiles table
        final profileData = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
            
        setState(() {
          // Update user data with profile information
          _userName = profileData['full_name'] ?? _userName;
          // Add other profile data as needed
        });
            }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchOpportunities() async {
    setState(() => _isLoading = true);
    final response = await _supabase.from('opportunities').select().order('date', ascending: true);
    setState(() {
      _opportunities = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
    _setupSwipeCards();
  }

  void _onFavoriteTap(Map<String, dynamic> opportunity) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add favorites'), backgroundColor: Colors.red),
      );
      return;
    }
    final userId = user.id;
    final opportunityId = opportunity['id'];
    if (opportunityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid opportunity'), backgroundColor: Colors.red),
      );
      return;
    }
    // Check if already in favorites
    final existing = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('opportunity_id', opportunityId)
        .maybeSingle();
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already in favorites!'), backgroundColor: Colors.orange),
      );
      return;
    }
    // Add to favorites
    try {
      await _supabase.from('favorites').insert({
        'user_id': userId,
        'opportunity_id': opportunityId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to favorites: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _setupSwipeCards() {
    _swipeItems = _opportunities.map((data) {
      return SwipeItem(
        content: data,
        likeAction: () {},
        nopeAction: () {},
        superlikeAction: () {
          _onFavoriteTap(data);
        },
      );
    }).toList();
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.88;
    final cardHeight = size.height * 0.52;
    final showNoMore = _swipeItems.isEmpty || _matchEngine.currentItem == null;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Voluncheers' : _selectedIndex == 1 ? 'Favorites' : _selectedIndex == 3 ? 'Profile' : '',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _selectedIndex == 1
            ? const FavoritesScreen()
            : _selectedIndex == 2
              ? ChatScreen() // <-- this is what was missing!
              : _selectedIndex == 3
                ? const ProfileScreen()
                  : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                      : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: showNoMore
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.celebration, color: Colors.grey[400], size: 80),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'You have browsed all the opportunities for now!',
                                        style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton.icon(
                                        onPressed: _fetchOpportunities,
                                        icon: const Icon(Icons.refresh, color: Color(0xFF01311F)),
                                        label: const Text('Refresh', style: TextStyle(color: Color(0xFF01311F))),
                                      ),
                                    ],
                                  )
                                : SwipeCards(
                                    matchEngine: _matchEngine,
                                    itemBuilder: (context, index) {
                                      final data = _swipeItems[index].content as Map<String, dynamic>;
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OpportunityDetailsScreen(opportunity: data),
                                            ),
                                          );
                                        },
                                        child: _ModernOpportunityCard(
                                          data: data,
                                          width: cardWidth,
                                          height: cardHeight,
                                          isTop: true,
                                        ),
                                      );
                                    },
                                    onStackFinished: () {
                                      setState(() {});
                                    },
                                    upSwipeAllowed: false,
                                    fillSpace: true,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!showNoMore)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _ActionButton(
                                  icon: Icons.close,
                                  color: Colors.red,
                                  borderColor: Colors.red,
                                  onTap: () => _matchEngine.currentItem?.nope(),
                                ),
                                const SizedBox(width: 32),
                                _ActionButton(
                                  icon: Icons.star,
                                  color: const Color(0xFF01311F),
                                  borderColor: const Color(0xFF01311F),
                                  onTap: () => _matchEngine.currentItem?.superLike(),
                                ),
                                const SizedBox(width: 32),
                                _ActionButton(
                                  icon: Icons.check,
                                  color: Colors.green,
                                  borderColor: Colors.green,
                                  onTap: () => _matchEngine.currentItem?.like(),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _ModernOpportunityCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final double width;
  final double height;
  final bool isTop;
  const _ModernOpportunityCard({required this.data, required this.width, required this.height, required this.isTop});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF01311F);
    return Center(
      child: Material(
        elevation: isTop ? 12 : 4,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Image
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: data['image_url'] != null && data['image_url'].toString().isNotEmpty
                    ? Image.network(
                        data['image_url'],
                        width: width,
                        height: height,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF01311F).withOpacity(0.1),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: Color(0xFF01311F),
                                size: 40,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFF01311F).withOpacity(0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF01311F),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFF01311F).withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: Color(0xFF01311F),
                            size: 40,
                          ),
                        ),
                      ),
              ),
              // Dark overlay for better text visibility
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // Top info row
              Positioned(
                top: 18,
                left: 18,
                right: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: darkGreen.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: darkGreen, width: 2),
                        ),
                        child: Text(
                          data['organisation'] ?? '',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: darkGreen.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: darkGreen, width: 2),
                        ),
                        child: Text(
                          _formatTimeRange(data['start_time'], data['end_time']),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Title
              Positioned(
                left: 20,
                right: 20,
                bottom: 90,
                child: Text(
                  data['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Date
              Positioned(
                left: 20,
                right: 20,
                bottom: 60,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        data['date'] != null ? data['date'].toString() : '',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Location
              Positioned(
                left: 20,
                right: 20,
                bottom: 30,
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        data['location'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(dynamic start, dynamic end) {
    if (start == null || end == null) return '';
    try {
      final startTime = DateFormat('HH:mm:ss').parse(start.toString());
      final endTime = DateFormat('HH:mm:ss').parse(end.toString());
      final startFormatted = DateFormat('h:mm a').format(startTime);
      final endFormatted = DateFormat('h:mm a').format(endTime);
      return '$startFormatted - $endFormatted';
    } catch (_) {
      return '$start - $end';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.color, required this.borderColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
} 