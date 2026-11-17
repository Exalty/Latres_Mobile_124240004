import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  bool _isLoadingLocation = false;
  String? _locationError;
  UserLocationInfo? _locationInfo;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '124240004';
    });
  }

  Future<void> _fetchLocationAndCinemas() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final info = await LocationService.getUserLocationAndNearbyCinemas();
      setState(() {
        _locationInfo = info;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _openMaps(double lat, double lng, String label) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Konfirmasi Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(color: Color(0xFFCBD5E1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 46,
                  backgroundColor: Color(0xFF1E293B),
                  child: Icon(Icons.person, size: 52, color: Color(0xFF818CF8)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Praktikum Pemrograman Aplikasi Mobile',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // CARD LBS / LOCATION-BASED SERVICES (BIOSKOP & WILAYAH NONTON)
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF334155), width: 0.8),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: Color(0xFFEC4899)),
                            SizedBox(width: 8),
                            Text(
                              'LBS: Bioskop Terdekat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF1F5F9),
                              ),
                            ),
                          ],
                        ),
                        if (_isLoadingLocation)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFEC4899),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFF334155)),
                    if (_locationError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0x33EF4444),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEF4444), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationError!,
                                style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_locationInfo != null) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.my_location, size: 18, color: Color(0xFF818CF8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wilayah: ${_locationInfo!.city}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFFF1F5F9),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _locationInfo!.formattedAddress,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Rekomendasi Bioskop Terdekat dari Anda:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._locationInfo!.nearbyCinemas.take(3).map((cinema) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF334155), width: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cinema.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFF1F5F9),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Jarak: ${cinema.distanceInKm.toStringAsFixed(2)} km',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.directions, color: Color(0xFF6366F1), size: 22),
                                tooltip: 'Rute Google Maps',
                                onPressed: () => _openMaps(cinema.latitude, cinema.longitude, cinema.name),
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else ...[
                      const Text(
                        'Temukan bioskop dan tempat nonton terdekat dari posisi Anda saat ini secara real-time via GPS.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEC4899),
                          side: const BorderSide(color: Color(0xFFEC4899)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isLoadingLocation ? null : _fetchLocationAndCinemas,
                        icon: const Icon(Icons.radar_rounded, size: 18),
                        label: Text(_locationInfo == null ? 'Cek Bioskop Terdekat' : 'Perbarui Lokasi GPS'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // CARD KESAN & PESAN
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF334155), width: 0.8),
              ),
              elevation: 3,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_quote_rounded, color: Color(0xFF818CF8)),
                        SizedBox(width: 8),
                        Text(
                          'Kesan & Pesan Praktikum',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF1F5F9),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 20, color: Color(0xFF334155)),
                    Text(
                      'Kesan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF818CF8),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Praktikum Mobile semester ini sangat seru, menantang, dan memberikan banyak pemahaman mendalam tentang pengembangan aplikasi modern dengan Flutter, API integration, serta local database Hive.',
                      style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFFCBD5E1)),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Pesan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF818CF8),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Terima kasih banyak untuk seluruh asisten praktikum atas bimbingan dan kesabarannya selama satu semester ini. Semoga praktikum ke depannya semakin keren dan sukses selalu untuk mas/mbak aslab!',
                      style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFFCBD5E1)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 3,
                  shadowColor: const Color(0x66EF4444),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
