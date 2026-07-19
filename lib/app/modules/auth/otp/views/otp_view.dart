  import 'package:bellspalsy_app/app/modules/auth/otp/controllers/otp_controller.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';

  class OtpView extends StatefulWidget {
    const OtpView({super.key});

    @override
    State<OtpView> createState() => _OtpViewState();
  }

  class _OtpViewState extends State<OtpView> {
    final List<TextEditingController> _controllers =
        List.generate(4, (_) => TextEditingController());
    final List<FocusNode> _focusNodes =
        List.generate(4, (_) => FocusNode());

    @override
    void dispose() {
      for (final c in _controllers) {
        c.dispose();
      }
      for (final f in _focusNodes) {
        f.dispose();
      }
      super.dispose();
    }

    void _onChanged(String value, int index) {
      if (value.isNotEmpty && index < 3) {
        _focusNodes[index + 1].requestFocus();
      }
      if (value.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    void _onSubmit() {

    final otp = _controllers.map((c) => c.text).join();

    final controller = Get.find<OtpController>();

    controller.verifyOtp(otp);

  }

    @override
    Widget build(BuildContext context) {
      final Color mainGreen = const Color(0xFF4A7561);
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: IconButton(
                    //     onPressed: () => Get.back(),
                    //     icon: const Icon(Icons.arrow_back),
                    //     padding: EdgeInsets.zero,
                    //     constraints: const BoxConstraints(),
                    //   ),
                    // ),

                    SizedBox(height: size.height * 0.06),

                    const Text(
                      'Code OTP',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const Text(
                      'Verification',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Enter the code we sent to your email\n'
                      'to reset your password',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 36),

                    Row(
                      children: List.generate(4, (i) {
                        return Container(
                          width: 56,
                          height: 56,
                          margin: EdgeInsets.only(right: i < 3 ? 16 : 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: mainGreen,
                              ),
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              onChanged: (v) => _onChanged(v, i),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 48),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          
                        ),
                        child: const Text(
                          'SUBMIT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
