import 'dart:convert';
import 'package:bellspalsy_app/app/modules/article/models/article_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "https://therapalsy.web.id";

  static Uri uri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');

    final baseUri = Uri.parse(
      normalizedBaseUrl.startsWith('http://') ||
              normalizedBaseUrl.startsWith('https://')
          ? normalizedBaseUrl
          : 'https://$normalizedBaseUrl',
    );

    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return baseUri.replace(
      path: (baseUri.path + normalizedPath).replaceAll('//', '/'),
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "access_token";

  Future<String?> getToken() async => await _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = uri("/auth/register");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 201) {
      throw Exception(data["message"] ?? "Register gagal");
    }
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = uri("/auth/login");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Login gagal");
    }

    final token = data["access_token"] as String;
    await saveToken(token);
    return data;
  }

  Future<List<dynamic>> getLoginHistory() async {
    final token = await getToken();

    if (token == null) {
      throw Exception("Belum login");
    }

    final url = uri("/auth/login-history");

    final res = await http.get(
      url,

      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception("Gagal ambil history");
    }

    return data;
  }

  Future<Map<String, dynamic>> me() async {
    final token = (await getToken())?.trim();
    print("STORED TOKEN = $token");

    if (token == null || token.isEmpty) {
      throw Exception("Belum login (token kosong)");
    }

    final url = uri("/me");
    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print("ME status=${res.statusCode} body=${res.body}");

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Gagal ambil profil");
    }
    return data;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception("Belum login");

    final url = uri("/profile");

    final res = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "avatar_url": avatarUrl ?? "",
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"]);
    }

    return data;
  }

  Future<String> uploadAvatar(String filePath) async {
    final token = await getToken();
    if (token == null) throw Exception("Belum login");

    final url = uri("/profile/avatar");

    final request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";

    request.files.add(await http.MultipartFile.fromPath("avatar", filePath));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Upload avatar gagal");
    }

    // return avatar_url dari backend (contoh: /uploads/user_1.jpg)
    return (data["avatar_url"] ?? "").toString();
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      uri('/auth/verify'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Verifikasi OTP gagal.');
    }

    return body;
  }

  Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      uri('/auth/verify-reset-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Verifikasi OTP reset gagal.');
    }

    return body;
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final response = await http.post(
      uri('/auth/forgot-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email.trim().toLowerCase()}),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Gagal mengirim OTP reset password.');
    }

    return body;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      uri('/auth/reset-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Reset password gagal.');
    }

    return body;
  }

  Future<List<Article>> getArticles() async {
    final url = uri("/api/articles");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode body response menjadi List
        List data = json.decode(response.body);

        // Ubah List Map menjadi List Object Article
        return data.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception('Gagal ambil data artikel: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }
}
