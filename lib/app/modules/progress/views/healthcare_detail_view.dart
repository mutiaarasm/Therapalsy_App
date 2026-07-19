  import 'package:flutter/material.dart';
  import 'package:url_launcher/url_launcher.dart';


  class HealthcareDetailView extends StatelessWidget {
    Future<void> openGoogleMaps() async {
  final lat = double.tryParse(place['latitude']?.toString() ?? '') ??
              double.tryParse(place['lat']?.toString() ?? '') ??
              0;

  final lng = double.tryParse(place['longitude']?.toString() ?? '') ??
              double.tryParse(place['lng']?.toString() ?? '') ??
              0;

  final url = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '&origin=$userLat,$userLng'
    '&destination=$lat,$lng'
    '&travelmode=driving',
  );

  await launchUrl(url, mode: LaunchMode.externalApplication);
}
  final dynamic place;
  final double userLat;
  final double userLng;
    

  const HealthcareDetailView({
  super.key,
  required this.place,
  required this.userLat,
  required this.userLng,
});

    @override
    Widget build(BuildContext context) {
      const mainGreen = Color(0xFF306A5A);

      return Scaffold(
        backgroundColor: const Color(0xFFF7FAF9),
        appBar: AppBar(
          title: const Text('Detail Rumah Sakit'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: ListView(
          children: [
            Container(
              height: 220,
              color: mainGreen.withOpacity(0.12),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 90,
                color: mainGreen,
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      place['name'] ?? 'Healthcare Place',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      place['type'] ?? 'healthcare',
                      style: const TextStyle(
                        color: mainGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),

                   _InfoRow(
                    icon: Icons.access_time_rounded,
                    title: 'Jam Operasional',
                    value: place['operational_hours'] ?? '-',
                  ),

                  _InfoRow(
                    icon: Icons.phone_rounded,
                    title: 'Telepon',
                    value: place['phone'] ?? '-',
                  ),

                  (place['website'] != null && place['website'].toString().isNotEmpty)
                    ? GestureDetector(
                        onTap: () async {
                          final url = Uri.parse(place['website']);

                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: _InfoRow(
                          icon: Icons.language_rounded,
                          title: 'Website',
                          value: place['website'],
                        ),
                      )
                    : _InfoRow(
                        icon: Icons.language_rounded,
                        title: 'Website',
                        value: '-',
                      ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: openGoogleMaps,
                        icon: const Icon(Icons.map_rounded),
                        label: const Text('Lihat Lokasi Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  class _InfoRow extends StatelessWidget {
    final IconData icon;
    final String title;
    final String value;

    const _InfoRow({
      required this.icon,
      required this.title,
      required this.value,
    });

    @override
    Widget build(BuildContext context) {
      const mainGreen = Color(0xFF306A5A);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: mainGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }