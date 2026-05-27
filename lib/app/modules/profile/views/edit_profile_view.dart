import 'dart:io';

import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
 final ApiService api = ApiService();

final TextEditingController usernameController = TextEditingController();
final TextEditingController emailController = TextEditingController();

final ImagePicker _picker = ImagePicker();
XFile? _pickedAvatar;

bool _loading = true;
String _avatarUrlFromServer = "";


Future<void> _pickAvatar() async {
  final XFile? file = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );
  if (file == null) return;

  setState(() {
    _pickedAvatar = file;
  });
}


  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
  try {
    final data = await api.me();

    setState(() {
      usernameController.text = (data["name"] ?? "").toString();
      emailController.text = (data["email"] ?? "").toString();
      _avatarUrlFromServer = (data["avatar_url"] ?? "").toString();
      _loading = false;
    });
  } catch (e) {
    setState(() => _loading = false);
    Get.snackbar(
      "Error",
      e.toString().replaceAll("Exception: ", ""),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
 Future<void> _saveChange() async {

  final name = usernameController.text.trim();
  final email = emailController.text.trim();

  if (name.isEmpty) {
    Get.snackbar("Gagal", "Username tidak boleh kosong");
    return;
  }

  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  try {

    /// upload avatar dulu
    if (_pickedAvatar != null) {

      final avatarUrlFromApi =
          await api.uploadAvatar(_pickedAvatar!.path);

      _avatarUrlFromServer = avatarUrlFromApi;
    }

    final result = await api.updateProfile(
      name: name,
      email: email,
      avatarUrl: _avatarUrlFromServer,
    );

    Get.back();

    /// cek apakah email berubah
    if (result["email_changed"] == true) {

      Get.snackbar(
        "Perlu verifikasi",
        "Kode OTP dikirim ke email baru",
      );

      Get.toNamed(
        Routes.OTP,
        arguments: email,
      );

    } else {

      Get.back(result: true);

    }

  } catch (e) {

    Get.back();

    Get.snackbar(
      "Error",
      e.toString(),
    );

  }

}

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color mainGreen = const Color(0xFF306A5A);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(height: 250, width: double.infinity, color: mainGreen),

          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      children: [
                        // AppBar custom
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white),
                                onPressed: () => Get.back(), // kalau batal, ga perlu result true
                              ),
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    'EDIT PROFILE',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Avatar (sementara asset)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 6),
                                color: Colors.white,
                              ),
                             child: ClipOval(
                                child: _pickedAvatar != null
                                    ? Image.file(
                                        File(_pickedAvatar!.path),
                                        fit: BoxFit.cover,
                                      )
                                    : (_avatarUrlFromServer.isNotEmpty
                                        ? Image.network(
                                            "${ApiService.baseUrl}$_avatarUrlFromServer",
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Image.asset(
                                              'assets/images/avatar.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.asset(
                                            'assets/images/avatar.jpg',
                                            fit: BoxFit.cover,
                                          )),
                              ),
                            ),

                            // ICON EDIT (pojok kanan bawah)
                            Positioned(
                              bottom: 18,
                              right: 18,
                              child: InkWell(
                                onTap: _pickAvatar,
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: mainGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(height: 16),

                        // Form
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Username',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.black26),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: mainGreen, width: 1.5),
                                  ),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),

                              const SizedBox(height: 18),

                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.black26),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: mainGreen, width: 1.5),
                                  ),
                                ),
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Save
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveChange,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'SAVE CHANGE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
