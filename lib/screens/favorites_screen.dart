import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_config.dart';
import 'opportunity_details_screen.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final SupabaseClient _supabase = SupabaseConfig.client;
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() => _isLoading = true);
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _favorites = [];
        _isLoading = false;
      });
      return;
    }
    final response = await _supabase
        .from('favorites')
        .select('opportunity_id, opportunities(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    // Flatten the data
    final favs = (response as List)
        .map((e) => e['opportunities'] as Map<String, dynamic>)
        .where((e) => e != null)
        .toList();
    setState(() {
      _favorites = favs;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(String opportunityId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('opportunity_id', opportunityId);
    _fetchFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from favorites'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgColor,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text('No favorites yet!', style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final data = _favorites[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OpportunityDetailsScreen(
                              opportunity: data,
                              fromFavorites: true,
                            ),
                          ),
                        );
                      },
                      child: Container(
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
                        child: Row(
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: data['image_url'] != null && data['image_url'].toString().isNotEmpty
                                  ? Image.network(
                                      data['image_url'],
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 90,
                                      height: 90,
                                      color: const Color(0xFF01311F).withOpacity(0.08),
                                      child: const Icon(Icons.image, size: 40, color: Color(0xFF01311F)),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'] ?? '',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['organisation'] ?? '',
                                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: Color(0xFF01311F)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            data['location'] ?? '',
                                            style: const TextStyle(fontSize: 14, color: Color(0xFF01311F)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 15, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            _formatDateTime(data['date'], data['start_time'], data['end_time']),
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Remove button
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _removeFavorite(data['id'].toString()),
                                tooltip: 'Remove from favorites',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDateTime(dynamic date, dynamic start, dynamic end) {
    String formattedDate = '';
    try {
      formattedDate = DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(date.toString()));
    } catch (_) {
      formattedDate = date?.toString() ?? '';
    }
    String formattedTime = '';
    try {
      final startTime = DateFormat('HH:mm:ss').parse(start.toString());
      final endTime = DateFormat('HH:mm:ss').parse(end.toString());
      formattedTime = '${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}';
    } catch (_) {
      formattedTime = (start != null && end != null) ? '$start - $end' : '';
    }
    return '$formattedDate${formattedTime.isNotEmpty ? ' | $formattedTime' : ''}';
  }
} 