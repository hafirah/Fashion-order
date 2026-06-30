import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fashion_order/auth/login_page.dart';
import 'package:fashion_order/home_page.dart';
import 'package:fashion_order/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {

    super.initState();

    Timer(
      const Duration(seconds: 5),
      () {
        checkLogin();
      },
    );

  }

  Future<void> checkLogin() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    bool isLogin =
        prefs.getBool("login") ?? false;

    if (!mounted) return;

    if (isLogin) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),

      );

    } else {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),

      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColor.background,

      body: Center(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Container(

              width: 120,
              height: 120,

              decoration: BoxDecoration(

                color: AppColor.primary,

                borderRadius:
                    BorderRadius.circular(30),

                boxShadow: [

                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),

                ],

              ),

              child: const Icon(
                Icons.checkroom,
                color: Colors.white,
                size: 65,
              ),

            ),

            const SizedBox(height: 25),

            const Text(

              "Fashion Order",

              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),

            ),

            const SizedBox(height: 10),

            Text(

              "Kelola Pesanan Fashion dengan Mudah",

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 15,
                color: AppColor.darkGrey,
              ),

            ),

            const SizedBox(height: 40),

            CircularProgressIndicator(
              color: AppColor.primary,
            ),

          ],

        ),

      ),

    );

  }

}