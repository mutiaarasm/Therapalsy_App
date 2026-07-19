import 'package:get/get.dart';
import 'package:bellspalsy_app/services/api_service.dart';

class ProfileController extends GetxController {
  final ApiService api = ApiService();

  final isLoading = false.obs;
  final name = ''.obs;
  final email = ''.obs;
  final avatarUrl = ''.obs;
  final error = ''.obs;

  // Berubah hanya ketika foto profil diganti.
  final avatarRevision = 0.obs;

  String get fullAvatarUrl {
    final String rawUrl = avatarUrl.value.trim();

    if (rawUrl.isEmpty) {
      return '';
    }

    final String url =
        rawUrl.startsWith('http://') || rawUrl.startsWith('https://')
        ? rawUrl
        : ApiService.uri(rawUrl).toString();

    if (avatarRevision.value == 0) {
      return url;
    }

    final String separator = url.contains('?') ? '&' : '?';

    return '$url${separator}v=${avatarRevision.value}';
  }

  @override
  void onInit() {
    super.onInit();

    // Hanya dijalankan ketika controller pertama kali dibuat.
    loadMe();
  }

  Future<void> loadMe({bool refreshAvatar = false}) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      error.value = '';

      final Map<String, dynamic> data = await api.me();

      final String newName = (data['name'] ?? '').toString();

      final String newEmail = (data['email'] ?? '').toString();

      final String newAvatarUrl = (data['avatar_url'] ?? '').toString().trim();

      final bool avatarChanged = newAvatarUrl != avatarUrl.value;

      name.value = newName;
      email.value = newEmail;
      avatarUrl.value = newAvatarUrl;

      
      if (newAvatarUrl.isNotEmpty && (avatarChanged || refreshAvatar)) {
        avatarRevision.value = DateTime.now().millisecondsSinceEpoch;
      }
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void updateLocalProfile({
    required String newName,
    required String newEmail,
    String? newAvatarUrl,
    bool avatarChanged = false,
  }) {
    name.value = newName;
    email.value = newEmail;

    if (newAvatarUrl != null && newAvatarUrl.trim().isNotEmpty) {
      avatarUrl.value = newAvatarUrl.trim();
    }

    if (avatarChanged) {
      avatarRevision.value = DateTime.now().millisecondsSinceEpoch;
    }
  }

  void clear() {
    name.value = '';
    email.value = '';
    avatarUrl.value = '';
    avatarRevision.value = 0;
    error.value = '';
    isLoading.value = false;
  }
}
