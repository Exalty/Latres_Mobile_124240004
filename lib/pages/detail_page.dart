import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tv_show.dart';
import '../services/api_service.dart';

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
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        _favoritesBox.put(show.id, show);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke Favorit'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
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
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showDetailFuture = ApiService.fetchShowDetail(widget.showId);
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan'));
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
                    height: 320,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 320,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 320,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                  )
                else
                  Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.tv, size: 64, color: Colors.grey),
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                              size: 30,
                            ),
                            onPressed: () => _toggleFavorite(show),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            show.rating != null ? '${show.rating} / 10' : 'Rating: N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Genres
                      if (show.genres.isNotEmpty) ...[
                        const Text(
                          'Genre',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: show.genres.map((genre) {
                            return Chip(
                              label: Text(genre),
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Summary / Overview
                      const Text(
                        'Overview / Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _cleanSummary(show.summary),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
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
