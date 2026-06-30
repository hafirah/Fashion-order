import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pesanan_model.dart';
import '../../theme.dart';
import 'edit_pesanan_page.dart';
import '../../services/api.dart';
import '../pdf/pdf_service.dart';

class DetailPesananPage extends StatefulWidget {
  final PesananModel pesanan;

  const DetailPesananPage({
    super.key,
    required this.pesanan,
  });

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  late PesananModel pesanan;
  final rupiah = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    pesanan = widget.pesanan;
  }

  Color statusColor(String status) {
    switch (status) {
      case "Pending":
        return const Color.fromARGB(255, 233, 162, 188);
      case "Diproses":
        return const Color.fromARGB(255, 116, 170, 216);
      case "Selesai":
        return const Color.fromARGB(255, 112, 206, 190);
      default:
        return Colors.grey;
    }
  }

  Widget itemDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> bukaEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPesananPage(pesanan: pesanan),
      ),
    );

    if (result != null && result is PesananModel) {
      setState(() {
        pesanan = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: bukaEdit,
            icon: const Icon(Icons.edit),
          ),

          // ================= PDF BUTTON FIX =================
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              PdfService.cetakDetail(
                nama: pesanan.namaPelanggan ?? "-",
                noHp: pesanan.noHp ?? "-",
                alamat: pesanan.alamat ?? "-",
                produk: pesanan.namaProduk ?? "-",
                tanggal: pesanan.tanggalPesan ?? "-",
                deadline: pesanan.deadline ?? "-",
                harga: pesanan.harga ?? "0",
                status: pesanan.status ?? "-",
                ukuran: pesanan.catatanUkuran ?? "-",
                biaya: pesanan.catatanBiaya ?? "-",
                tambahan: pesanan.catatanTambahan ?? "-",
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: statusColor(pesanan.status ?? ""),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pesanan.status ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= FOTO =================
            if (pesanan.foto != null && pesanan.foto!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          body: Center(
                            child: InteractiveViewer(
                              minScale: 1,
                              maxScale: 5,
                              child: Image.network(
                                "${Api.baseUrl}/uploads/${pesanan.foto}",
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      "${Api.baseUrl}/uploads/${pesanan.foto}",
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 150,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Belum ada foto referensi",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

            // ================= DATA =================
            itemDetail("Nama Pelanggan", pesanan.namaPelanggan ?? "-"),
            itemDetail("No HP", pesanan.noHp ?? "-"),
            itemDetail("Alamat", pesanan.alamat ?? "-"),
            itemDetail("Nama Produk", pesanan.namaProduk ?? "-"),

            itemDetail(
              "Tanggal Pesan",
              pesanan.tanggalPesan != null
                  ? DateFormat("dd MMMM yyyy", "id")
                      .format(DateTime.parse(pesanan.tanggalPesan!))
                  : "-",
            ),

            itemDetail(
              "Deadline",
              pesanan.deadline != null
                  ? DateFormat("dd MMMM yyyy", "id")
                      .format(DateTime.parse(pesanan.deadline!))
                  : "-",
            ),

            itemDetail(
              "Harga",
              "Rp ${rupiah.format(int.tryParse(pesanan.harga ?? "0") ?? 0)}",
            ),

            itemDetail("Catatan Ukuran", pesanan.catatanUkuran ?? "-"),
            itemDetail("Catatan Biaya", pesanan.catatanBiaya ?? "-"),
            itemDetail("Catatan Tambahan", pesanan.catatanTambahan ?? "-"),
          ],
        ),
      ),
    );
  }
}