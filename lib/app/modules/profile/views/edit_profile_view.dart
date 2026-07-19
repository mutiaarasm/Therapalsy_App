import 'dart:io';

import 'package:bellspalsy_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState
    extends State<EditProfileView> {
  final ApiService api = ApiService();

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  late final ProfileController profileController;

  XFile? _pickedAvatar;

  String _avatarUrlFromServer = '';

  bool _saving = false;

  static const Color mainGreen =
      Color(0xFF306A5A);

  @override
  void initState() {
    super.initState();

    profileController =
        Get.find<ProfileController>();

    // Ambil data langsung dari ProfileController.
    // Tidak melakukan request /me lagi.
    usernameController.text =
        profileController.name.value;

    emailController.text =
        profileController.email.value;

    _avatarUrlFromServer =
        profileController.avatarUrl.value;
  }

  Future<void> _pickAvatar() async {
    if (_saving) return;

    try {
      final XFile? selectedImage =
          await _picker.pickImage(
        source: ImageSource.gallery,

        // Mengurangi ukuran file yang diunggah.
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (selectedImage == null || !mounted) {
        return;
      }

      setState(() {
        _pickedAvatar = selectedImage;
      });
    } catch (e) {
      Get.snackbar(
        'Gagal memilih foto',
        e.toString().replaceAll(
              'Exception: ',
              '',
            ),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _saveChange() async {
    if (_saving) return;

    final String name =
        usernameController.text.trim();

    final String newEmail =
        emailController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Username tidak boleh kosong.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newEmail.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Email tidak boleh kosong.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!GetUtils.isEmail(newEmail)) {
      Get.snackbar(
        'Gagal',
        'Format email tidak valid.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      String updatedAvatarUrl =
          _avatarUrlFromServer;

      final bool avatarChanged =
          _pickedAvatar != null;

      // Upload hanya jika pengguna memilih foto baru.
      if (_pickedAvatar != null) {
        updatedAvatarUrl =
            await api.uploadAvatar(
          _pickedAvatar!.path,
        );
      }

      final result =
          await api.updateProfile(
        name: name,
        email: newEmail,
        avatarUrl: updatedAvatarUrl,
      );

      final bool emailChanged =
          result['email_changed'] == true;

      // Perbarui data lokal langsung.
      // Tidak memanggil /me kembali.
      profileController.updateLocalProfile(
        newName: name,

        // Email lama dipertahankan sampai OTP berhasil.
        newEmail: emailChanged
            ? profileController.email.value
            : newEmail,

        newAvatarUrl: updatedAvatarUrl,
        avatarChanged: avatarChanged,
      );

      _avatarUrlFromServer =
          updatedAvatarUrl;

      if (emailChanged) {
        Get.snackbar(
          'Perlu verifikasi',
          'Kode OTP telah dikirim ke email baru.',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Mengganti halaman Edit Profile dengan halaman OTP.
        Get.offNamed(
          Routes.OTP,
          arguments: {
            'email': newEmail,
            'type': 'edit',
          },
        );
      } else {
        Get.back(result: true);

        Get.snackbar(
          'Berhasil',
          'Profil berhasil diperbarui.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal memperbarui profil',
        e.toString().replaceAll(
              'Exception: ',
              '',
            ),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _fallbackAvatar() {
    return Image.asset(
      'assets/images/avatar.jpg',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }

  Widget _buildAvatarImage() {
    // Setelah memilih gambar, tampilkan langsung dari file HP.
    if (_pickedAvatar != null) {
      return Image.file(
        File(_pickedAvatar!.path),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
      );
    }

    final String avatarUrl =
        profileController.fullAvatarUrl;

    if (avatarUrl.isEmpty) {
      return _fallbackAvatar();
    }

    return CachedNetworkImage(
      imageUrl: avatarUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      alignment: Alignment.center,

      // Hanya menentukan lebar agar foto tidak mleyot.
      memCacheWidth: 400,

      fadeInDuration:
          const Duration(milliseconds: 150),

      placeholder: (context, url) {
        return _fallbackAvatar();
      },

      errorWidget: (context, url, error) {
        return _fallbackAvatar();
      },
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.black26,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: mainGreen,
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.black12,
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9F8),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background bagian atas.
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF306A5A),
                  Color(0xFF4D8878),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                        .viewInsets
                        .bottom +
                    30,
              ),
              child: Column(
                children: [
                  // App bar.
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 10,
                      left: 8,
                      right: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons
                                .arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                          onPressed: _saving
                              ? null
                              : () => Get.back(),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'EDIT PROFILE',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w700,
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

                  // Foto profil.
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        padding:
                            const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.14),
                              blurRadius: 20,
                              offset:
                                  const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child:
                              _buildAvatarImage(),
                        ),
                      ),

                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _saving
                                ? null
                                : _pickAvatar,
                            borderRadius:
                                BorderRadius.circular(
                              999,
                            ),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration:
                                  BoxDecoration(
                                color: mainGreen,
                                shape:
                                    BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(
                                      0.15,
                                    ),
                                    blurRadius: 8,
                                    offset:
                                        const Offset(
                                      0,
                                      4,
                                    ),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Form.
                  Container(
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    padding:
                        const EdgeInsets.fromLTRB(
                      22,
                      24,
                      22,
                      24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.black
                            .withOpacity(0.06),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.06),
                          blurRadius: 18,
                          offset:
                              const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 7),

                        TextField(
                          controller:
                              usernameController,
                          enabled: !_saving,
                          textInputAction:
                              TextInputAction.next,
                          decoration:
                              _inputDecoration(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 7),

                        TextField(
                          controller:
                              emailController,
                          enabled: !_saving,
                          keyboardType:
                              TextInputType
                                  .emailAddress,
                          textInputAction:
                              TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration:
                              _inputDecoration(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          onSubmitted: (_) {
                            if (!_saving) {
                              _saveChange();
                            }
                          },
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saving
                                ? null
                                : _saveChange,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  mainGreen,
                              foregroundColor:
                                  Colors.white,
                              disabledBackgroundColor:
                                  mainGreen
                                      .withOpacity(
                                0.55,
                              ),
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2.5,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Icon(
                                        Icons
                                            .save_rounded,
                                        size: 19,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        'SAVE CHANGE',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              15.5,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                          letterSpacing:
                                              1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
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