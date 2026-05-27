import 'package:flutter/material.dart';

class PrivacyPoliceView extends StatelessWidget {
  const PrivacyPoliceView({Key? key}) : super(key: key);

  // Titik kecil
  Widget _dot() => Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.only(top: 6, right: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF306A5A),
          shape: BoxShape.circle,
        ),
      );

  // Judul section
  Widget _sectionTitle(String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dot(),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF306A5A),
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ],
      );

  // Konten section
  Widget _sectionContent(String text) => Padding(
        padding: const EdgeInsets.only(left: 26, top: 6, bottom: 22),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PRIVACY POLICY',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ListView(
            children: const [
              SizedBox(height: 4),
              Center(
                child: Text(
                  'Last Update 12 Jan 2026',
                  style: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 15,
                  ),
                ),
              ),
              SizedBox(height: 22),

              // OVERVIEW
              _SectionBlock(
                title: 'OVERVIEW',
                content:
                    "TheraPalsy values your privacy. This Privacy Policy explains how we collect, use, protect, and share your personal information when you use the TheraPalsy application. By accessing or using the Application, you agree to the terms set forth in this Privacy Policy.",
              ),

              // INFORMATION
              _SectionBlock(
                title: 'Information We Collect',
                content:
                    "Information You Provide: Information you enter directly into the App, such as Bell’s Palsy symptom data you enter, medical history, and other data related to your use of the App.\n\nAutomatically Collected Information: Information we collect automatically through your use of the App, including usage data, device data, and location data (depending on your device settings).",
              ),

              // USE
              _SectionBlock(
                title: 'Use Of Information',
                content:
                    "We use the information we collect for various purposes. Analyzing Bell’s Palsy symptoms to provide analysis and therapy recommendations based on the symptom data you enter.",
              ),

              SizedBox(height: 30),
              _UnderstandButton(),
              SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Helper Widgets (pure UI) =====

class _SectionBlock extends StatelessWidget {
  final String title;
  final String content;

  const _SectionBlock({
    required this.title,
    required this.content,
  });

  Widget _dot() => Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.only(top: 6, right: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF306A5A),
          shape: BoxShape.circle,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dot(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF306A5A),
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 26, top: 6, bottom: 22),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnderstandButton extends StatelessWidget {
  const _UnderstandButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF306A5A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: const Text(
            'UNDERSTAND',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
