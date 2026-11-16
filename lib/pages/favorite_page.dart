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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 70, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada show favorit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
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
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                              color: Colors.grey[200],
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 50,
                              height: 70,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 24),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 70,
                            color: Colors.grey[300],
                            child: const Icon(Icons.tv, size: 24),
                          ),
                  ),
                  title: Text(
                    show.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        show.rating != null ? show.rating!.toString() : 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      box.delete(show.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${show.name} dihapus dari favorit'),
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
