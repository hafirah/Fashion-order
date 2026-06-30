import 'package:flutter/material.dart';

import 'package:fashion_order/services/api_service.dart';
import 'package:fashion_order/theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> register() async {

    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field wajib diisi"),
        ),
      );

      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Konfirmasi password tidak sesuai"),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      var response = await ApiService.register(

        usernameController.text,
        emailController.text,
        passwordController.text,

      );

      if (response["success"] == true) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Register berhasil, silakan login",
            ),
          ),
        );

        Navigator.pop(context);

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ??
                  "Register gagal",
            ),
          ),
        );

      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Terjadi kesalahan : $e",
          ),
        ),
      );

    }

    setState(() {
      isLoading = false;
    });

  }

  @override
  void dispose() {

    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColor.background,

      appBar: AppBar(

        backgroundColor: AppColor.primary,

        foregroundColor: Colors.white,

        title: const Text(
          "Register",
        ),

        centerTitle: true,

      ),

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding: const EdgeInsets.all(20),

            child: Column(

              children: [

                const SizedBox(height: 20),

                CircleAvatar(

                  radius: 50,

                  backgroundColor: AppColor.primary,

                  child: const Icon(
                    Icons.person_add,
                    size: 50,
                    color: Colors.white,
                  ),

                ),

                const SizedBox(height: 20),

                const Text(

                  "Buat Akun Baru",

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),

                ),

                const SizedBox(height: 30),

                Card(

                  elevation: 3,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Padding(

                    padding: const EdgeInsets.all(20),

                    child: Column(

                      children: [

                        TextField(

                          controller: usernameController,

                          decoration: InputDecoration(

                            labelText: "Username",

                            prefixIcon: const Icon(
                              Icons.person,
                            ),

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),

                          ),

                        ),

                        const SizedBox(height: 20),

                        TextField(

                          controller: emailController,

                          decoration: InputDecoration(

                            labelText: "Email",

                            prefixIcon: const Icon(
                              Icons.email,
                            ),

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),

                          ),

                        ),

                        const SizedBox(height: 20),

                        TextField(

                          controller: passwordController,

                          obscureText: obscurePassword,

                          decoration: InputDecoration(

                            labelText: "Password",

                            prefixIcon: const Icon(
                              Icons.lock,
                            ),

                            suffixIcon: IconButton(

                              onPressed: () {

                                setState(() {

                                  obscurePassword =
                                  !obscurePassword;

                                });

                              },

                              icon: Icon(

                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,

                              ),

                            ),

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),

                          ),

                        ),

                        const SizedBox(height: 20),

                        TextField(

                          controller:
                          confirmPasswordController,

                          obscureText:
                          obscureConfirmPassword,

                          decoration: InputDecoration(

                            labelText:
                            "Konfirmasi Password",

                            prefixIcon: const Icon(
                              Icons.lock_outline,
                            ),

                            suffixIcon: IconButton(

                              onPressed: () {

                                setState(() {

                                  obscureConfirmPassword =
                                  !obscureConfirmPassword;

                                });

                              },

                              icon: Icon(

                                obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,

                              ),

                            ),

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),

                          ),

                        ),

                        const SizedBox(height: 30),

                        SizedBox(

                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(

                            style:
                            ElevatedButton.styleFrom(

                              backgroundColor:
                              AppColor.primary,

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(
                                  15,
                                ),

                              ),

                            ),

                            onPressed:
                            isLoading ? null : register,

                            child: isLoading

                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )

                                : const Text(

                              "Register",

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),

                            ),

                          ),

                        ),

                      ],

                    ),

                  ),

                )

              ],

            ),

          ),

        ),

      ),

    );

  }

}