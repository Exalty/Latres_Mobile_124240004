import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CinemaVenue {
  final String name;
  final String chain; // XXI, CGV, Cinepolis
  final double latitude;
  final double longitude;
  double distanceInKm;

  CinemaVenue({
    required this.name,
    required this.chain,
    required this.latitude,
    required this.longitude,
    this.distanceInKm = 0.0,
  });
}

class UserLocationInfo {
  final Position position;
  final String formattedAddress;
  final String city;
  final List<CinemaVenue> nearbyCinemas;

  UserLocationInfo({
    required this.position,
    required this.formattedAddress,
    required this.city,
    required this.nearbyCinemas,
  });
}

class LocationService {
  static final Geocoding _geocoding = Geocoding();

  // Database bioskop referensi (Yogyakarta & kota besar sekitarnya)
  static final List<CinemaVenue> _cinemaDatabase = [
    CinemaVenue(
      name: 'Cinema XXI Plaza Ambarrukmo',
      chain: 'XXI',
      latitude: -7.782875,
      longitude: 110.401243,
    ),
    CinemaVenue(
      name: 'CGV Pakuwon Mall Jogja',
      chain: 'CGV',
      latitude: -7.758983,
      longitude: 110.399587,
    ),
    CinemaVenue(
      name: 'Empire XXI Urip Sumoharjo',
      chain: 'XXI',
      latitude: -7.783152,
      longitude: 110.385501,
    ),
    CinemaVenue(
      name: 'Jogja City XXI (JCM)',
      chain: 'XXI',
      latitude: -7.755490,
      longitude: 110.360340,
    ),
    CinemaVenue(
      name: 'Cinepolis Lippo Plaza Jogja',
      chain: 'Cinepolis',
      latitude: -7.785081,
      longitude: 110.392095,
    ),
    CinemaVenue(
      name: 'CGV JWalk Babarsari',
      chain: 'CGV',
      latitude: -7.779774,
      longitude: 110.413813,
    ),
    CinemaVenue(
      name: 'Sleman City Hall XXI',
      chain: 'XXI',
      latitude: -7.721473,
      longitude: 110.360171,
    ),
  ];

  /// Memeriksa dan meminta izin lokasi pengguna
  static Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Tes apakah GPS di perangkat aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi (GPS) pada perangkat Anda dinonaktifkan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin akses lokasi ditolak oleh pengguna.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin akses lokasi ditolak secara permanen. Mohon izinkan lewat Pengaturan HP.',
      );
    }

    // Ambil posisi saat ini
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Mengambil detail alamat dan menghitung bioskop terdekat
  static Future<UserLocationInfo> getUserLocationAndNearbyCinemas() async {
    final position = await determinePosition();
    if (position == null) {
      throw Exception('Gagal mendapatkan posisi pengguna.');
    }

    // Reverse Geocoding
    String formattedAddress =
        'Koordinat: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    String city = 'Wilayah Anda';

    try {
      final List<Placemark> placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        city = place.subAdministrativeArea ?? place.locality ?? 'Wilayah Anda';
        formattedAddress = [
          if (place.street != null && place.street!.isNotEmpty) place.street,
          if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
          if (place.locality != null && place.locality!.isNotEmpty) place.locality,
          if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty)
            place.subAdministrativeArea,
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty)
            place.administrativeArea,
        ].join(', ');
      }
    } catch (_) {
      // Jika reverse geocode gagal (misal koneksi/emulator), fallback ke koordinat
    }

    // Hitung jarak ke setiap bioskop menggunakan rumus geodesi Geolocator
    final List<CinemaVenue> cinemasWithDistance = _cinemaDatabase.map((cinema) {
      final double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        cinema.latitude,
        cinema.longitude,
      );
      final double distanceInKm = distanceInMeters / 1000.0;
      return CinemaVenue(
        name: cinema.name,
        chain: cinema.chain,
        latitude: cinema.latitude,
        longitude: cinema.longitude,
        distanceInKm: distanceInKm,
      );
    }).toList();

    // Urutkan dari yang paling dekat
    cinemasWithDistance.sort((a, b) => a.distanceInKm.compareTo(b.distanceInKm));

    return UserLocationInfo(
      position: position,
      formattedAddress: formattedAddress,
      city: city,
      nearbyCinemas: cinemasWithDistance,
    );
  }
}
