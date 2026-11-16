import 'package:hive/hive.dart';

class TvShow {
  final int id;
  final String name;
  final String? imageUrl;
  final double? rating;
  final List<String> genres;
  final String? summary;

  TvShow({
    required this.id,
    required this.name,
    this.imageUrl,
    this.rating,
    required this.genres,
    this.summary,
  });

  /// Parse from TVMaze API JSON response
  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      imageUrl: json['image'] != null ? json['image']['medium'] : null,
      rating: json['rating'] != null
          ? (json['rating']['average'] as num?)?.toDouble()
          : null,
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : [],
      summary: json['summary'],
    );
  }

  /// Convert to Map (for Hive storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'genres': genres,
      'summary': summary,
    };
  }

  /// Create from Map (from Hive storage)
  factory TvShow.fromMap(Map<dynamic, dynamic> map) {
    return TvShow(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      rating: map['rating'],
      genres: List<String>.from(map['genres'] ?? []),
      summary: map['summary'],
    );
  }
}

/// Hive TypeAdapter for storing TvShow in local database
class TvShowAdapter extends TypeAdapter<TvShow> {
  @override
  final int typeId = 0;

  @override
  TvShow read(BinaryReader reader) {
    final map = reader.readMap();
    return TvShow.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, TvShow obj) {
    writer.writeMap(obj.toMap());
  }
}
