import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fashion_order/services/api_service.dart';
import '../../home_page.dart';
import 'register_page.dart';
import '../../../theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {

    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password wajib diisi"),
        ),
      );

      return;
    }
    setState(() {
      isLoading = true;
    });

    try {

      var response = await ApiService.login(
        usernameController.text,
        passwordController.text,
      );

      if (response["success"] == true) {

        SharedPreferences prefs =
            await SharedPreferences.getInstance();

        await prefs.setBool("login", true);

        await prefs.setString(
          "username",
          response["data"]["username"],
        );

        await prefs.setString(
          "email",
          response["data"]["email"],
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username atau Password salah"),
          ),
        );

      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan : $e"),
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
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const SizedBox(height: 80),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColor.primary,
                  child: const Icon(
                    Icons.checkroom,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Fashion Order",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Silahkan login terlebih dahulu",
                  style: TextStyle(
                    color: AppColor.darkGrey,
                  ),
                ),

                const SizedBox(height: 40),

                Card(

                  elevation: 3,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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

                        const SizedBox(height: 30),

                        SizedBox(

                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(

                            style: ElevatedButton.styleFrom(

                              backgroundColor:
                                  AppColor.primary,

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),

                            ),

                            onPressed:
                                isLoading ? null : login,

                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(

                                    "Login",

                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),

                                  ),

                          ),

                        ),

                        const SizedBox(height: 10),

                        TextButton(

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    const RegisterPage(),
                              ),

                            );

                          },

                          child: const Text(
                            "Belum punya akun? Register",
                          ),

                        )

                      ],

                    ),

                  ),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}