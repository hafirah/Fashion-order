import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  // ================= FORMAT HELPER =================
  static String formatRupiah(String value) {
    final number = int.tryParse(value) ?? 0;
    return NumberFormat.decimalPattern('id').format(number);
  }

  static String safe(String? value) {
    return (value == null || value.trim().isEmpty) ? "-" : value;
  }

  // ================= INVOICE NUMBER =================
  static String generateInvoiceId() {
    final now = DateTime.now();
    return "INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}";
  }

  // ================= SAVE FILE =================
  static Future<File> savePdf(pw.Document pdf, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ================= SHARE PDF =================
  static Future<void> sharePdf(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }

  // ================= MAIN PDF =================
  static Future<File> cetakDetail({
    required String nama,
    required String noHp,
    required String alamat,
    required String produk,
    required String tanggal,
    required String deadline,
    required String harga,
    required String status,
    required String ukuran,
    required String biaya,
    required String tambahan,
  }) async {
    final pdf = pw.Document();
    final invoiceId = generateInvoiceId();

    final tanggalCetak = DateFormat(
      "dd MMMM yyyy - HH:mm",
      "id_ID",
    ).format(DateTime.now());

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "INVOICE PESANAN",
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      invoiceId,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),

              // ================= DATA =================
              item("Nama Pelanggan", safe(nama)),
              item("No HP", safe(noHp)),
              item("Alamat", safe(alamat)),
              item("Produk", safe(produk)),
              item("Tanggal Pesan", safe(tanggal)),
              item("Deadline", safe(deadline)),
              item("Harga", "Rp ${formatRupiah(harga)}"),
              item("Catatan Ukuran", safe(ukuran)),
              item("Catatan Biaya", safe(biaya)),
              item("Catatan Tambahan", safe(tambahan)),

              pw.SizedBox(height: 15),

              // ================= STATUS =================
              pw.Row(
                children: [
                  pw.Text(
                    "Status",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: statusColor(status),
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      safe(status),
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),

              // ================= SIGNATURE =================
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text("Admin"),
                      pw.SizedBox(height: 50),
                      pw.Text("(...........................)"),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text("Pelanggan"),
                      pw.SizedBox(height: 50),
                      pw.Text(
                        safe(nama),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Dicetak: $tanggalCetak",
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Center(
                child: pw.Text(
                  "Fashion Order © 2026",
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    final file = await savePdf(pdf, invoiceId);

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );

    return file;
  }

  // ================= ITEM =================
  static pw.Widget item(String title, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.7),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 140,
            padding: const pw.EdgeInsets.all(8),
            color: PdfColors.grey200,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                value.isEmpty ? "-" : value,
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATUS COLOR =================
  static PdfColor statusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return PdfColor.fromInt(0xFFE9A2BC);
      case "diproses":
        return PdfColor.fromInt(0xFF74AAD8);
      case "selesai":
        return PdfColor.fromInt(0xFF70CEBE);
      default:
        return PdfColors.grey;
    }
  }
}