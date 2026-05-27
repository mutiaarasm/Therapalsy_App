import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetectionHistoryView extends StatelessWidget {
  const DetectionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainGreen = const Color(0xFF316B5C);

    // Dummy data (nanti ganti dari API)
    final List<Map<String, dynamic>> dummyHistory = [
      {"day": 1, "percent": 20, "date": "2026-01-12 09:20"},
      {"day": 2, "percent": 35, "date": "2026-01-13 09:25"},
      {"day": 3, "percent": 50, "date": "2026-01-14 09:15"},
      {"day": 4, "percent": 43, "date": "2026-01-15 09:40"},
      {"day": 5, "percent": 0,  "date": "2026-01-16 09:10"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Detection History",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          children: [
            // Header / info kecil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    offset: Offset(0, 6),
                    color: Color(0x14000000),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.insights, color: mainGreen),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Riwayat hasil deteksi wajah kamu dari hari ke hari.",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // nanti kalau sudah pakai API, tombol ini jadi fetch ulang
                      Get.snackbar("Info", "Nanti tombol ini buat refresh data",
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    child: const Text("Refresh"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: ListView.separated(
                itemCount: dummyHistory.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final item = dummyHistory[i];
                  final int day = item["day"];
                  final int percent = item["percent"];
                  final String date = item["date"];

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      // nanti bisa ke halaman detail
                      Get.snackbar(
                        "Detail",
                        "Klik Day $day (dummy)",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12,
                            offset: Offset(0, 6),
                            color: Color(0x14000000),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Badge Day
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: mainGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              "D$day",
                              style: TextStyle(
                                color: mainGreen,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Day $day",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  date,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // progress bar mini
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: (percent.clamp(0, 100)) / 100.0,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFEAEAEA),
                                    valueColor: AlwaysStoppedAnimation(mainGreen),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // percent
                          Text(
                            "$percent%",
                            style: TextStyle(
                              color: mainGreen,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
