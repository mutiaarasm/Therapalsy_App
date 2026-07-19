import 'package:bellspalsy_app/app/routes/app_pages.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final Color mainGreen = const Color(0xFF316B5C);

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final TextEditingController nameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  final TextEditingController confirmC = TextEditingController();

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passC.dispose();
    confirmC.dispose();
    super.dispose();
  }

   Future<void> _onSignUp() async {

  final name = nameC.text.trim();
  final email = emailC.text.trim();
  final pass = passC.text;
  final confirm = confirmC.text;

  if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
    Get.snackbar('Gagal', 'Semua field wajib diisi');
    return;
  }

  if (pass != confirm) {
    Get.snackbar('Gagal', 'Password tidak sama');
    return;
  }

  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  try {

    final api = ApiService();

    await api.register(
      name: name,
      email: email,
      password: pass,
    );

    Get.back();

    Get.snackbar(
      "Berhasil",
      "Kode OTP sudah dikirim ke email",
    );

    /// pindah ke OTP screen
    Get.offNamed(
  Routes.OTP,
  arguments: {
    'email': email.trim().toLowerCase(),
    'type': 'register',
  },
);

  } catch (e) {

    Get.back();

    Get.snackbar(
      "Register gagal",
      e.toString(),
    );

  }

}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB5CFC2),
            Color(0xFFEFF5F2),
          ],
        ),
      ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                //   Align(
                //   alignment: Alignment.centerLeft,
                //   child: Transform.translate(
                //     offset: const Offset(-8, -10), // kiri 8px, atas 6px
                //     child: IconButton(
                //       onPressed: () => Get.back(),
                //       icon: const Icon(Icons.arrow_back),
                //       padding: EdgeInsets.zero,
                //       constraints: const BoxConstraints(),
                //     ),
                //   ),
                // ),

                  // jarak atas responsif (bukan 142 fix)
                  SizedBox(height: size.height * 0.04),

                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a new account\nand start your journey with us.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 28),

                  _RoundedTextField(controller: nameC, hint: 'Name'),
                  const SizedBox(height: 16),

                  _RoundedTextField(
                    controller: emailC,
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  _RoundedTextField(
                    controller: passC,
                    hint: 'Password',
                    obscureText: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _RoundedTextField(
                    controller: confirmC,
                    hint: 'Confirm Password',
                    obscureText: _obscureConfirm,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1, color: Colors.black26)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Already have an account?',
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ),
                      const Expanded(child: Divider(thickness: 1, color: Colors.black26)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed(Routes.LOGIN),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const _RoundedTextField({
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
    );
  }
}
