import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tv_show.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class DetailPage extends StatefulWidget {
  final int showId;

  const DetailPage({super.key, required this.showId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<TvShow> _showDetailFuture;
  late Box _favoritesBox;

  @override
  void initState() {
    super.initState();
    _showDetailFuture = ApiService.fetchShowDetail(widget.showId);
    _favoritesBox = Hive.box('favorites');
  }

  // Remove HTML tags from TVMaze summary
  String _cleanSummary(String? rawSummary) {
    if (rawSummary == null || rawSummary.isEmpty) {
      return 'No overview available.';
    }
    final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return rawSummary.replaceAll(exp, '').trim();
  }

  bool _isFavorite(int id) {
    return _favoritesBox.containsKey(id);
  }

  void _toggleFavorite(TvShow show) {
    setState(() {
      if (_isFavorite(show.id)) {
        _favoritesBox.delete(show.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari Favorit'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 1),
          ),
        );
        NotificationService.showInstantNotification(
          id: show.id,
          title: 'Dihapus dari Favorit 💔',
          body: '${show.name} telah dihapus dari daftar serial favoritmu.',
        );
      } else {
        _favoritesBox.put(show.id, show);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke Favorit'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 1),
          ),
        );
        NotificationService.showInstantNotification(
          id: show.id,
          title: 'Disimpan ke Favorit! ❤️',
          body: '${show.name} berhasil ditambahkan ke daftar tontonan favoritmu.',
        );
      }
    });
  }

  void _showReminderDialog(TvShow show) {
    int selectedSeconds = 10;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: Row(
                children: [
                  const Icon(Icons.alarm_add_rounded, color: Color(0xFF6366F1)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Pasang Pengingat Nonton',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingatkan saya untuk menonton "${show.name}" dalam:',
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('10 Detik (Demo)'),
                        selected: selectedSeconds == 10,
                        onSelected: (val) => setDialogState(() => selectedSeconds = 10),
                      ),
                      ChoiceChip(
                        label: const Text('1 Menit'),
                        selected: selectedSeconds == 60,
                        onSelected: (val) => setDialogState(() => selectedSeconds = 60),
                      ),
                      ChoiceChip(
                        label: const Text('5 Menit'),
                        selected: selectedSeconds == 300,
                        onSelected: (val) => setDialogState(() => selectedSeconds = 300),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.notifications_active_rounded, size: 18),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    await NotificationService.scheduleNotification(
                      id: show.id + 1000,
                      title: '⏰ Waktunya Nonton Serial! 🍿',
                      body: 'Episode baru atau serial "${show.name}" sudah siap kamu nikmati!',
                      secondsFromNow: selectedSeconds,
                    );

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pengingat berhasil dipasang untuk $selectedSeconds detik lagi!',
                        ),
                        backgroundColor: const Color(0xFF6366F1),
                      ),
                    );
                  },
                  label: const Text('Set Pengingat'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Show'),
      ),
      body: FutureBuilder<TvShow>(
        future: _showDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showDetailFuture = ApiService.fetchShowDetail(widget.showId);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Data tidak ditemukan',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            );
          }

          final show = snapshot.data!;
          final isFav = _isFavorite(show.id);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Show Image
                if (show.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: show.imageUrl!,
                    height: 340,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 340,
                      color: const Color(0xFF1E293B),
                      child: const Center(
                        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 340,
                      color: const Color(0xFF1E293B),
                      child: const Icon(Icons.broken_image, size: 64, color: Color(0xFF94A3B8)),
                    ),
                  )
                else
                  Container(
                    height: 250,
                    color: const Color(0xFF1E293B),
                    child: const Icon(Icons.tv, size: 64, color: Color(0xFF94A3B8)),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Favorite button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              show.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF8FAFC),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                              size: 32,
                            ),
                            onPressed: () => _toggleFavorite(show),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Rating & Reminder Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 24),
                              const SizedBox(width: 6),
                              Text(
                                show.rating != null ? '${show.rating} / 10' : 'Rating: N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF818CF8),
                              side: const BorderSide(color: Color(0xFF6366F1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.alarm_add_rounded, size: 18),
                            label: const Text('Ingatkan Nonton'),
                            onPressed: () => _showReminderDialog(show),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Genres
                      if (show.genres.isNotEmpty) ...[
                        const Text(
                          'Genre',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: show.genres.map((genre) {
                            return Chip(
                              label: Text(
                                genre,
                                style: const TextStyle(color: Color(0xFFE0E7FF), fontWeight: FontWeight.w500),
                              ),
                              backgroundColor: const Color(0xFF312E81),
                              side: const BorderSide(color: Color(0xFF4338CA)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Summary / Overview
                      const Text(
                        'Overview / Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _cleanSummary(show.summary),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
