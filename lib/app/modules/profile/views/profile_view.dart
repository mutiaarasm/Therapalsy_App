import 'dart:ui';
import 'package:bellspalsy_app/app/modules/PrivacyPolice/views/privacy_police_view.dart';
import 'package:bellspalsy_app/app/modules/faq/views/faq_view.dart';
import 'package:bellspalsy_app/app/modules/profile/views/edit_profile_view.dart';
import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bellspalsy_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
   final ProfileController controller =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put<ProfileController>(
                ProfileController(),
              );
    const Color mainGreen = Color(0xFF306A5A);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Stack(
        children: [
          // ===== Header background (gradient) =====
          Container(
            height: 310,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  mainGreen,
                  mainGreen.withOpacity(0.88),
                  mainGreen.withOpacity(0.72),
                ],
              ),
            ),
          ),
          // blobs
          Positioned(top: -80, right: -60, child: _Blob(color: Colors.white.withOpacity(0.14), size: 220)),
          Positioned(bottom: MediaQuery.of(context).size.height - 420, left: -70, child: _Blob(color: Colors.white.withOpacity(0.10), size: 240)),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 18),
              children: [
                _buildAppBar(),

                const SizedBox(height: 12),

                // ===== Profile Card =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      child: Column(
                        children: [
                          Obx(() => _buildAvatar(controller.fullAvatarUrl)),
                          const SizedBox(height: 14),

                          Obx(() {
                            if (controller.isLoading.value) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (controller.error.isNotEmpty) {
                              return Column(
                                children: [
                                  Text(
                                    controller.error.value,
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: controller.loadMe,
                                    child: const Text("Coba lagi"),
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Text(
                                  controller.name.value.isEmpty ? "-" : controller.name.value,
                                  style: const TextStyle(
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.email.value.isEmpty ? "-" : controller.email.value,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.black.withOpacity(0.55),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          }),

                          const SizedBox(height: 14),

                          _buildEditButton(mainGreen, controller),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ===== Menu Section =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SectionLabel(text: "Settings"),
                      SizedBox(height: 10),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      _ProfileMenuCard(
                        icon: Icons.privacy_tip_outlined,
                        text: 'Privacy Policy',
                        onTap: () => Get.to(() => const PrivacyPoliceView()),
                      ),
                      const SizedBox(height: 10),
                      _ProfileMenuCard(
                        icon: Icons.help_outline_rounded,
                        text: 'FAQ',
                        onTap: () => Get.to(() => const FaqScreen()),
                      ),
                      const SizedBox(height: 10),
                      _ProfileMenuCard(
                        icon: Icons.history_rounded,
                        text: 'Sign In History',
                         onTap: () => Get.toNamed(Routes.SIGN_IN_HISTORY)
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ===== Danger zone =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SectionLabel(text: "Account"),
                      SizedBox(height: 10),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _ProfileMenuCard(
                    icon: Icons.logout_rounded,
                    text: 'Sign Out',
                    isDanger: true,
                    onTap: _showLogoutDialog,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== App Bar =====
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
      child: SizedBox(
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
            const Text(
              'PROFILE',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Avatar =====
Widget _buildAvatar(String avatarUrl) {
  Widget fallbackAvatar() {
    return Image.asset(
      'assets/images/avatar.jpg',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }

  return Container(
    width: 108,
    height: 108,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: ClipOval(
      child: avatarUrl.trim().isEmpty
          ? fallbackAvatar()
          : CachedNetworkImage(
              imageUrl: avatarUrl,

              width: double.infinity,
              height: double.infinity,

              fit: BoxFit.cover,
              alignment: Alignment.center,

              // Hanya width agar rasio foto tidak mleyot.
              memCacheWidth: 216,

              fadeInDuration:
                  const Duration(
                milliseconds: 150,
              ),

              placeholder: (_, __) {
                return fallbackAvatar();
              },

              errorWidget: (_, __, ___) {
                return fallbackAvatar();
              },
            ),
    ),
  );
}
  // ===== Edit Button =====
  Widget _buildEditButton(
  Color mainGreen,
  ProfileController controller,
) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton.icon(
      onPressed: () async {
        await Get.to(
          () => const EditProfileView(),
        );

        // Tidak perlu loadMe().
        // EditProfileView memperbarui controller lokal.
      },
      icon: const Icon(
        Icons.edit_rounded,
        size: 18,
      ),
      label: const Text(
        'EDIT PROFILE',
        style: TextStyle(
          fontSize: 13.8,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: mainGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(999),
        ),
      ),
    ),
  );
}
}

// ===== Logout Dialog =====
void _showLogoutDialog() {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // handle bar
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          const SizedBox(height: 18),

          // icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFEF4444),
              size: 34,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Logout Account?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "You will be signed out from this device.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.black.withOpacity(0.55),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 22),

          // BUTTONS
          Row(
            children: [

              // cancel
              Expanded(
                child: OutlinedButton(
                  onPressed: Get.back,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // logout
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Tutup bottom sheet terlebih dahulu.
                    if (Get.isBottomSheetOpen == true) {
                      Get.back();
                    }

                    // Bersihkan dan hapus controller akun lama.
                    if (Get.isRegistered<ProfileController>()) {
                      final ProfileController profileController =
                          Get.find<ProfileController>();

                      profileController.clear();

                      Get.delete<ProfileController>(
                        force: true,
                      );
                    }

                    // Hapus token dari secure storage.
                    await ApiService().logout();

                    // Seluruh route lama dibuang.
                    Get.offAllNamed(Routes.LOGIN);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    ),
    isDismissible: true,
  );
}

// ===== Menu Card =====
class _ProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isDanger;

  const _ProfileMenuCard({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconBg = isDanger ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6F4);
    final iconColor = isDanger ? const Color(0xFFEF4444) : const Color(0xFF306A5A);
    final titleColor = isDanger ? const Color(0xFFEF4444) : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.2,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.black.withOpacity(0.35), size: 26),
          ],
        ),
      ),
    );
  }
}

// ===== Section Label =====
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Colors.black.withOpacity(0.45),
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

// ===== Glass card =====
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.65)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}