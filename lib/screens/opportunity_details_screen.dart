import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/constants.dart';

class OpportunityDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> opportunity;
  final bool fromFavorites;
  const OpportunityDetailsScreen({Key? key, required this.opportunity, this.fromFavorites = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = opportunity['image_url'] as String?;
    final title = opportunity['title'] ?? '';
    final organisation = opportunity['organisation'] ?? '';
    final date = opportunity['date'] ?? '';
    final startTime = opportunity['start_time'] ?? '';
    final endTime = opportunity['end_time'] ?? '';
    final location = opportunity['location'] ?? '';
    final description = opportunity['description'] ?? '';
    
    String formattedDate = date;
    try {
      formattedDate = DateFormat('EEEE, MMM d, yyyy').format(DateTime.parse(date));
    } catch (_) {}
    String formattedTime = '';
    try {
      final start = DateFormat('HH:mm:ss').parse(startTime);
      final end = DateFormat('HH:mm:ss').parse(endTime);
      formattedTime = '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';
    } catch (_) {
      formattedTime = '$startTime - $endTime';
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (fromFavorites) {
              Navigator.of(context).pop(); // Will return to FavoritesScreen
            } else {
              Navigator.of(context).pop(); // Will return to HomeScreen
            }
          },
        ),
        title: const Text('Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      color: const Color(0xFF01311F).withOpacity(0.08),
                      child: const Icon(Icons.image, size: 60, color: Color(0xFF01311F)),
                    ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Organizer: $organisation', style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF01311F).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Color(0xFF01311F)),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 15, color: Color(0xFF01311F)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time, size: 20, color: Color(0xFF01311F)),
                      const SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: const TextStyle(fontSize: 15, color: Color(0xFF01311F)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF01311F)),
                      const SizedBox(width: 8),
                      Text(
                        location,
                        style: const TextStyle(fontSize: 15, color: Color(0xFF01311F)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 18),
            const Text('Map View:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: (opportunity['latitude'] != null && opportunity['longitude'] != null)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(
                            double.tryParse(opportunity['latitude'].toString()) ?? 23.8103,
                            double.tryParse(opportunity['longitude'].toString()) ?? 90.4125,
                          ),
                          zoom: 14.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 40.0,
                                height: 40.0,
                                point: LatLng(
                                  double.tryParse(opportunity['latitude'].toString()) ?? 23.8103,
                                  double.tryParse(opportunity['longitude'].toString()) ?? 90.4125,
                                ),
                                child: const Icon(Icons.location_on, color: Color(0xFFC6AA58), size: 36),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text('Location not available', style: TextStyle(color: Colors.grey)),
                    ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Interested (right swipe) action
                      Navigator.of(context).pop(true); // Return true to indicate interest
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC6AA58),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Interested', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement Add to Favorites
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF01311F)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Add to Favorites', style: TextStyle(color: Color(0xFF01311F), fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
} 