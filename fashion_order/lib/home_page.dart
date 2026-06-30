import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fashion_order/auth/login_page.dart';
import 'package:fashion_order/omset/omset_page.dart';
import 'package:fashion_order/pesanan/pesanan_page.dart';
import 'package:fashion_order/services/api.dart';
import 'package:fashion_order/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  bool isLoading = true;
  int totalPesanan = 0;
  int pending = 0;
  int diproses = 0;
  int selesai = 0;
  int omsetBulan = 0;
  List deadlineList = [];

  String username = "";
  String email = "";
  String tanggalSekarang = "";
  String jamSekarang = "";

  Timer? timer;

  final List<String> pageTitles = [
  "Dashboard",
  "Pesanan",
  "Dashboard Omset",
  "Profil",
];

  @override
  void initState() {
    super.initState();
    loadUser();
    mulaiJam();
    getDashboard();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void mulaiJam() {
    tanggalSekarang = DateFormat(
      "EEEE, dd MMMM yyyy",
      "id_ID",
    ).format(DateTime.now());

    jamSekarang = DateFormat(
      "HH:mm:ss",
    ).format(DateTime.now());

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;
        setState(() {
          tanggalSekarang = DateFormat(
            "EEEE, dd MMMM yyyy",
            "id_ID",
          ).format(DateTime.now());

          jamSekarang = DateFormat(
            "HH:mm:ss",
          ).format(DateTime.now());
        });
      },
    );
  }

  Future<void> loadUser() async {
    final prefs =
        await SharedPreferences.getInstance();
    setState(() {
      username =
          prefs.getString("username") ?? "";
      email =
          prefs.getString("email") ?? "";
    });
  }
  Future<void> getDashboard() async {
    try {
      var response = await http.get(
        Uri.parse("${Api.baseUrl}/dashboard.php"),
      );
      var data = jsonDecode(response.body);

  setState(() {
  totalPesanan = int.parse(data["total"].toString());
  pending = int.parse(data["pending"].toString());
  diproses = int.parse(data["diproses"].toString());
  selesai = int.parse(data["selesai"].toString());
  
  omsetBulan =
      int.tryParse(data["omset_bulan"].toString()) ?? 0;

  deadlineList = data["deadline"] ?? [];

  isLoading = false;
});
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Widget dashboardPage() {
  return RefreshIndicator(
    onRefresh: getDashboard,
    child: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          "Halo, ${username.isEmpty ? "Admin" : username} 👋",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),

        Text(
          "Selamat datang kembali",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 6),

            Expanded(
              child: Text(
                tanggalSekarang,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            Icon(
              Icons.access_time,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 6),

            Text(
              "$jamSekarang WIB",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        
        const Text(
          "Statistik Pesanan",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),

        GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisSpacing: 14,
  mainAxisSpacing: 14,
  childAspectRatio: 1.0,
  children: [

buildCard(
  "Pending",
  "$pending",
  Icons.access_time_filled,
),

buildCard(
  "Diproses",
  "$diproses",
  Icons.autorenew_rounded,
),

buildCard(
  "Selesai",
  "$selesai",
  Icons.check_circle_outline_rounded,
),

buildCard(
  "Omset Bulan Ini",
  NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp",
    decimalDigits: 0,
  ).format(omsetBulan),
  Icons.account_balance_wallet_outlined,
),
    ],
    ),

    const SizedBox(height: 28),

const Text(
  "⚠ Deadline Terdekat",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

if (deadlineList.isEmpty)
  Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text("Tidak ada deadline terdekat"),
      ),
    ),
  )
else
  ...deadlineList.map((item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Container(
  width: 52,
  height: 52,
  decoration: BoxDecoration(
    color: Colors.red.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Icon(
    Icons.calendar_month_rounded,
    color: Colors.red,
    size: 28,
  ),
),
        title: Text(
          item["nama_pelanggan"],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item["nama_produk"]),
            const SizedBox(height: 4),
            Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 7,
  ),
  decoration: BoxDecoration(
    color: Colors.red.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(30),
    border: Border.all(
      color: Colors.red.withValues(alpha: 0.25),
    ),
  ),
  child: Text(
    item["keterangan"],
    style: const TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    ),
  ),
),
          ],
        ),
      ),
    );
  }),

    ],
    ),
  );
}

Widget buildCard(
  String title,
  String value,
  IconData icon,
) {
  Color cardColor;
 switch (title) {
  case "Pending":
    cardColor = const Color(0xFFFFC8DD);
    break;

  case "Diproses":
    cardColor = const Color(0xFFBDE0FE);
    break;

  case "Selesai":
    cardColor = const Color(0xFFD8F7F2);
    break;

  case "Omset Bulan Ini":
    cardColor = const Color(0xFFCDB4DB);
    break;

  default:
    cardColor = Colors.white;
}

  return Container(
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
  width: 58,
  height: 58,
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: 0.55),
    borderRadius: BorderRadius.circular(18),
  ),
  child: Icon(
    icon,
    size: 32,
    color: iconColor(title),
  ),
),

          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
          const SizedBox(height: 6),

          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    ),
  );
}

Color iconColor(String title) {
  switch (title) {
    case "Pending":
      return Colors.red;

    case "Diproses":
      return Colors.blue;

    case "Selesai":
      return Colors.teal;

    case "Omset Bulan Ini":
      return Colors.deepPurple;

    default:
      return Colors.black87;
  }
}

Widget deadlineCard(dynamic item) {
  return Card(
    elevation: 1,
    shadowColor: Colors.black12,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(
    color: Colors.grey.shade200,
  ),
),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor:
            Colors.orange.withValues(alpha: 0.15),
        child: const Icon(
          Icons.schedule,
          color: Colors.orange,
        ),
      ),
      title: Text(
        item["nama_pelanggan"],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(item["nama_produk"]),

          const SizedBox(height: 4),

          Text(
            item["status_deadline"],
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget pesananPage() {
  return const PesananPage();
}
Widget omsetPage() {
  return const OmsetPage();
}
Widget profilePage() {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFCDB4DB),
          Color(0xFFBDE0FE),
          Colors.white,
        ],
      ),
    ),
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 58,
                backgroundColor: const Color(0xFFCDB4DB),
                child: Text(
                  username.isEmpty
                      ? "A"
                      : username[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              username.isEmpty ? "Administrator" : username,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            Text(
              email,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 30),

            Card(
              elevation: 10,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFFBDE0FE),
                        child: const Icon(Icons.person),
                      ),
                      title: const Text("Username"),
                      subtitle: Text(username),
                    ),
                    const Divider(),

                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFFD8F7F2),
                        child: const Icon(Icons.email),
                      ),
                      title: const Text("Email"),
                      subtitle: Text(email),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Color(0xFFFFC8DD),
                        child: Icon(Icons.info),
                      ),
                      title: Text("Versi Aplikasi"),
                      subtitle: Text("Fashion Order v1.0.0"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  final List<Widget> pages = [
    dashboardPage(),
    pesananPage(),
    omsetPage(),
    profilePage(),
  ];
  return Scaffold(
    backgroundColor: AppColor.background,
    appBar: AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColor.primary,
      foregroundColor: Colors.white,
      title: Text(
        pageTitles[currentIndex],
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
  ),
),
    body: isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: AppColor.primary,
            ),
          )
        : AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 350,
            ),
            child: SizedBox.expand(
              key: ValueKey(currentIndex),
              child: pages[currentIndex],
            ),
          ),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 18,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 13,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: "Pesanan",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: "Omset",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profil",
          ),
        ],
      ),
    ),
  );
}
}