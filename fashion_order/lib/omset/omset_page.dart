import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../services/export_service.dart';
import '../services/api.dart';
import '../theme.dart';

class OmsetPage extends StatefulWidget {
  const OmsetPage({super.key});

  @override
  State<OmsetPage> createState() => _OmsetPageState();
}

class _OmsetPageState extends State<OmsetPage> {
  bool isLoading = true;

  final List<String> monthNames = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "Mei",
  "Jun",
  "Jul",
  "Agu",
  "Sep",
  "Okt",
  "Nov",
  "Des",
];

  int totalOmset = 0;
  int omsetBulan = 0;
  int jumlahSelesai = 0;

  List grafik = [];
  List laporan = [];

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final currency = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final res = await http.get(
        Uri.parse(
          "${Api.baseUrl}/omset.php?bulan=$selectedMonth&tahun=$selectedYear",
        ),
      );

      final json = jsonDecode(res.body);

      if (json["success"] == true) {
        totalOmset =
            int.tryParse(json["total_omset"].toString()) ?? 0;

        omsetBulan =
            int.tryParse(json["omset_bulan"].toString()) ?? 0;

        jumlahSelesai =
            int.tryParse(json["jumlah_selesai"].toString()) ?? 0;

        grafik = json["grafik"] ?? [];
        laporan = json["laporan"] ?? [];
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 145,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [

    CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Icon(
        icon,
        color: AppColor.primary,
      ),
    ),

    Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black54,
        fontWeight: FontWeight.w600,
      ),
    ),

    FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    ),
  ],
),
          
      ),
    );
  }

double get maxY {
  if (grafik.isEmpty) return 100;
  double max = 0;

  for (final item in grafik) {
    final value =
        double.tryParse(item["omset"].toString()) ?? 0;
    if (value > max) {
      max = value;
    }
  }

  // Kalau semua omset = 0
  if (max <= 0) {
    return 100;
  }
  return max * 1.2;
}

double get interval {
  if (maxY <= 100) return 20;
  return maxY / 5;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColor.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: getData,
              color: AppColor.primary,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [

                  const Text(
                    "Ringkasan Omset",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_month),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    items: List.generate(
                      12,(i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(monthNames[i]),
                      ),
                    ),
                  onChanged: (v) {
                    selectedMonth = v!;
                    getData();
                  },
                ),
              ),
              
            const SizedBox(width: 12),
            
          Expanded(
            child: DropdownButtonFormField<int>(
              value: selectedYear,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.date_range),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              items: List.generate(
                5,(i) {
                  final year = DateTime.now().year - 2 + i;
                  return DropdownMenuItem(
                    value: year,
                    child: Text("$year"),
                  );
                },
              ),
              onChanged: (v) {
                selectedYear = v!;
                getData();
              },
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 18),

      Align(
  alignment: Alignment.centerRight,
  child: PopupMenuButton<String>(
    icon: const Icon(Icons.download),
    itemBuilder: (_) => [
      const PopupMenuItem(
        value: "pdf",
        child: Text("Export PDF"),
      ),
      const PopupMenuItem(
        value: "excel",
        child: Text("Export Excel"),
      ),
    ],
onSelected: (value) async {

  if (value == "pdf") {

    await ExportService.exportPdf(
      totalOmset: totalOmset,
      omsetBulan: omsetBulan,
      jumlahSelesai: jumlahSelesai,
      rataRata: jumlahSelesai == 0
          ? 0
          : totalOmset ~/ jumlahSelesai,
      bulan: selectedMonth,
      tahun: selectedYear,
      laporan: laporan,
    );

  }

  if (value == "excel") {

    await ExportService.exportExcel(
      totalOmset: totalOmset,
      omsetBulan: omsetBulan,
      jumlahSelesai: jumlahSelesai,
      rataRata: jumlahSelesai == 0
          ? 0
          : totalOmset ~/ jumlahSelesai,
      bulan: selectedMonth,
      tahun: selectedYear,
      laporan: laporan,
    );

  }

},
  ),
),

                  Row(
                    children: [

                      statCard(
                        title: "Total Omset",
                        value: currency.format(totalOmset),
                        icon: Icons.payments,
                        color: const Color(0xffE9D5FF),
                      ),

                      const SizedBox(width: 14),

                      statCard(
                        title: "Omset Bulan",
                        value: currency.format(omsetBulan),
                        icon: Icons.calendar_month,
                        color: const Color(0xffD6E8FF),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [

                      statCard(
                        title: "Pesanan",
                        value: "$jumlahSelesai",
                        icon: Icons.shopping_bag,
                        color: const Color(0xffDDF5E3),
                      ),

                      const SizedBox(width: 14),

                      statCard(
                        title: "Rata-rata",
                        value: jumlahSelesai == 0
                        ? "Rp 0"
                        : currency.format(
                          totalOmset ~/ jumlahSelesai,
                        ),
                        icon: Icons.check_circle,
                        color: const Color(0xffFAD7E6),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Grafik Omset",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),
                  Container(
                    height: 240,
                    padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: grafik.isEmpty
                        ? const Center(
                            child: Text("Belum ada data"),
                          )
                        : BarChart(
                            BarChartData(
                              maxY: maxY,

                              borderData:
                                  FlBorderData(show: false),

                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: interval,
                              ),

                              titlesData: FlTitlesData(

                                topTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false),
                                ),

                                rightTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false),
                                ),

                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 42,
                                    interval: interval,
                                    getTitlesWidget:(value, meta) {
                                      if (value == 0) {
                                        return const Text(
                                          "0",
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        );
                                      }

                                      return Text(
                                        "${(value / 1000).round()}K",
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget:
                                        (value, meta) {

                                      final i = value.toInt();

                                      if (i >= grafik.length) {
                                        return const SizedBox();
                                      }

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(
                                          top: 8,
                                        ),
                                        child: Text(
                                          grafik[i]["bulan"],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              barGroups: List.generate(
                                grafik.length,
                                (index) {

                                  final omset =
                                      double.tryParse(
                                            grafik[index]["omset"]
                                                .toString(),
                                          ) ??
                                          0;

                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [

                                      BarChartRodData(
                                        toY: omset,
                                        width: 18,
                                        color: AppColor.primary,
                                        borderRadius:
                                            BorderRadius.circular(
                                                8),
                                      ),

                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}