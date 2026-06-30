import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<void> exportPdf({
    required int totalOmset,
    required int omsetBulan,
    required int jumlahSelesai,
    required int rataRata,
    required int bulan,
    required int tahun,
    required List laporan,
  }) async {
    final pdf = pw.Document();

    final currency = NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        build: (context) => [

          pw.Column(
  children: [

    pw.Text(
      "FASHION ORDER",
      style: pw.TextStyle(
        fontSize: 24,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.deepPurple,
      ),
    ),

    pw.SizedBox(height: 6),

    pw.Text(
      "Laporan Omset",
      style: const pw.TextStyle(
        fontSize: 16,
      ),
    ),

  ],
),

          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              "Fashion Order",
              style: const pw.TextStyle(
                fontSize: 14,
              ),
            ),
          ),

          pw.Divider(),
          pw.SizedBox(height: 20),
          pw.Text(
            "Periode : ${getMonthName(bulan)} $tahun",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),

          _row(
            "Total Omset",
            currency.format(totalOmset),
          ),

          _row(
            "Omset Bulan",
            currency.format(omsetBulan),
          ),

          _row(
            "Pesanan Selesai",
            "$jumlahSelesai",
          ),

          _row(
            "Rata-rata",
            currency.format(rataRata),
          ),

          pw.SizedBox(height: 30),

         pw.Divider(),

pw.SizedBox(height: 20),

pw.Text(
  "Detail Pesanan",
  style: pw.TextStyle(
    fontSize: 16,
    fontWeight: pw.FontWeight.bold,
  ),
),

pw.SizedBox(height: 10),

pw.Table.fromTextArray(
  border: pw.TableBorder.all(
    color: PdfColors.grey600,
    width: 0.5,
  ),

  headerStyle: pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.white,
  ),

  headerDecoration: const pw.BoxDecoration(
    color: PdfColors.deepPurple,
  ),

  cellAlignment: pw.Alignment.centerLeft,

  headers: const [
    "No",
    "Tanggal",
    "Pelanggan",
    "Produk",
    "Harga",
  ],

  data: List.generate(

    laporan.length,

    (index) {

      final item = laporan[index];

      return [

        "${index + 1}",

        item["tanggal_pesan"],

        item["nama_pelanggan"],

        item["nama_produk"],

        currency.format(
          int.parse(
            item["harga"].toString(),
          ),
        ),

      ];

    },

  ),

),

pw.SizedBox(height: 25),

pw.Divider(),

pw.Align(
  alignment: pw.Alignment.centerRight,
  child: pw.Text(
    "Dicetak : ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
  ),
),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      "${dir.path}/Laporan_Omset.pdf",
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Laporan Omset",
    );
  }

  static Future<void> exportExcel({
  required int totalOmset,
  required int omsetBulan,
  required int jumlahSelesai,
  required int rataRata,
  required int bulan,
  required int tahun,
  required List laporan,
}) async {

  final excel = Excel.createExcel();

  final sheet = excel['Laporan'];

  sheet.appendRow([
    TextCellValue("LAPORAN OMSET"),
  ]);

  sheet.appendRow([
    TextCellValue("Fashion Order"),
  ]);

  sheet.appendRow([]);

  sheet.appendRow([
    TextCellValue("Periode"),
    TextCellValue("$bulan/$tahun"),
  ]);

  sheet.appendRow([]);

  sheet.appendRow([
    TextCellValue("Total Omset"),
    IntCellValue(totalOmset),
  ]);

  sheet.appendRow([
    TextCellValue("Omset Bulan"),
    IntCellValue(omsetBulan),
  ]);

  sheet.appendRow([
    TextCellValue("Pesanan Selesai"),
    IntCellValue(jumlahSelesai),
  ]);

  sheet.appendRow([
    TextCellValue("Rata-rata"),
    IntCellValue(rataRata),
  ]);

  final bytes = excel.save();

  final dir = await getTemporaryDirectory();

  final file = File(
    join(dir.path, "Laporan_Omset.xlsx"),
  );

  await file.writeAsBytes(bytes!);

  await Share.shareXFiles(
    [XFile(file.path)],
    text: "Laporan Omset",
  );
}

  static pw.Widget _row(
    String title,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment:
            pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title),
          pw.Text(value),
        ],
      ),
    );
  }

  static String getMonthName(int month) {
  const months = [
    "",
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];

  return months[month];
}
}