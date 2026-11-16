import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/tv_show.dart';
import 'detail_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Box favoritesBox = Hive.box('favorites');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shows Favorit'),
      ),
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 70, color: Color(0xFF475569)),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada show favorit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final favoriteShows = box.values.toList().cast<TvShow>();

          return ListView.builder(
            itemCount: favoriteShows.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final show = favoriteShows[index];

              return Card(
                elevation: 3,
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF334155), width: 0.8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: show.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: show.imageUrl!,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 50,
                              height: 70,
                              color: const Color(0xFF0F172A),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 50,
                              height: 70,
                              color: const Color(0xFF334155),
                              child: const Icon(Icons.broken_image, size: 24, color: Color(0xFF94A3B8)),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 70,
                            color: const Color(0xFF334155),
                            child: const Icon(Icons.tv, size: 24, color: Color(0xFF94A3B8)),
                          ),
                  ),
                  title: Text(
                    show.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF1F5F9)),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        show.rating != null ? show.rating!.toString() : 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFCBD5E1)),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFF43F5E)),
                    onPressed: () {
                      box.delete(show.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${show.name} dihapus dari favorit'),
                          backgroundColor: const Color(0xFFEF4444),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(showId: show.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
