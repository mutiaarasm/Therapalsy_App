import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // List FAQ statis sesuai desain
  final List<Map<String, String>> faqList = [
    {
      "question": "Whats is Therapalsy?",
      "answer":
          "Therapalsy is an application designed to help users detect Bell's Palsy symptoms and provide appropriate therapy recommendations. The application uses intelligent algorithms to analyze symptoms and provide recovery guidance.",
    },
    {
      "question": "How does the Therapalsy app work?",
      "answer":
          "The app guides users through detection, therapy, and progress tracking to support recovery.",
    },
    {
      "question": "What are the features of TheraPalsy?",
      "answer":
          "Detection, guided therapy, progress tracking, and educational content.",
    },
    {
      "question": "Is Therapalsy available for iOS and Android devices?",
      "answer":
          "Currently available for Android and planned for iOS in the future.",
    },
    {
      "question": "Is there a cost to use the TheraPalsy app?",
      "answer":
          "TheraPalsy can be used for free with basic features.",
    },
    {
      "question": "Who developed the TheraPalsy application?",
      "answer":
          "Developed by Mutiara Syifa Maulida,Teknik Informatika, Universitas Harkat Negeri",
    },
  ];

  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "FAQ",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: faqList.length,
        separatorBuilder: (context, idx) => const Divider(
          color: Color(0xFFBDBDBD),
          height: 0,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, idx) {
          final isExpanded = expandedIndex == idx;
          final isFirst = idx == 0;
          final question = faqList[idx]['question']!;
          final answer = faqList[idx]['answer']!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    expandedIndex = isExpanded ? -1 : idx;
                  });
                },
                child: Container(
                  color:
                      isExpanded && isFirst ? const Color(0xFFFF7E7E) : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          question,
                          style: TextStyle(
                            color: isExpanded && isFirst
                                ? Colors.white
                                : const Color(0xFF2A3A3D),
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: isExpanded && isFirst
                            ? Colors.white
                            : const Color(0xFF2A3A3D),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded && answer.isNotEmpty)
                Container(
                  color: const Color(0xFFFF7E7E),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    answer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
