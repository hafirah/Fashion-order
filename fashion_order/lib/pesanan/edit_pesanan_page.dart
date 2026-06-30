import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pesanan_model.dart';
import '../../services/api_service.dart';
import '../../theme.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/api.dart';
import 'package:flutter/services.dart';

class EditPesananPage extends StatefulWidget {
  final PesananModel pesanan;
  const EditPesananPage({
    super.key,
    required this.pesanan,
  });

  @override
  State<EditPesananPage> createState() =>
      _EditPesananPageState();
}

class _EditPesananPageState
    extends State<EditPesananPage> {

  late TextEditingController namaPelangganController;
  late TextEditingController noHpController;
  late TextEditingController alamatController;
  late TextEditingController namaProdukController;
  late TextEditingController hargaController;
  late TextEditingController catatanUkuranController;
  late TextEditingController catatanBiayaController;
  late TextEditingController catatanTambahanController;

  bool isLoading = false;
  File? selectedImage;

final ImagePicker picker = ImagePicker();
  late String status;
  late DateTime tanggalPesan;
  late DateTime deadline;

  @override
  void initState() {
    super.initState();
    namaPelangganController = TextEditingController(
      text: widget.pesanan.namaPelanggan,
    );

    noHpController = TextEditingController(
      text: widget.pesanan.noHp,
    );

    alamatController = TextEditingController(
      text: widget.pesanan.alamat,
    );

    namaProdukController = TextEditingController(
      text: widget.pesanan.namaProduk,
    );

    hargaController = TextEditingController(
      text: NumberFormat.decimalPattern('id').format(
        int.tryParse(widget.pesanan.harga ?? "0") ?? 0,
      ),
    );

    catatanUkuranController = TextEditingController(
      text: widget.pesanan.catatanUkuran,
    );

    catatanBiayaController = TextEditingController(
      text: widget.pesanan.catatanBiaya,
    );

    catatanTambahanController = TextEditingController(
      text: widget.pesanan.catatanTambahan,
    );
    status = widget.pesanan.status ?? "Pending";

    tanggalPesan = DateTime.parse(
      widget.pesanan.tanggalPesan ??
          DateTime.now().toString(),
    );
    deadline = DateTime.parse(
      widget.pesanan.deadline ??
          DateTime.now().toString(),
    );
  }

  @override
  void dispose() {
    namaPelangganController.dispose();
    noHpController.dispose();
    alamatController.dispose();
    namaProdukController.dispose();
    hargaController.dispose();
    catatanUkuranController.dispose();
    catatanBiayaController.dispose();
    catatanTambahanController.dispose();
    super.dispose();
  }

  Future<void> pilihGambar() async {
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 70,
  );
  if (image != null) {
    setState(() {
      selectedImage = File(image.path);
    });
  }
}

  Future<void> pilihTanggalPesan() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tanggalPesan,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        tanggalPesan = picked;
      });
    }
  }

  Future<void> pilihDeadline() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        deadline = picked;
      });
    }
  }

  Future<void> updateData() async {
    if (namaPelangganController.text.isEmpty ||
        namaProdukController.text.isEmpty ||
        hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data wajib diisi"),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
    String namaFile = widget.pesanan.foto ?? "";
    if (selectedImage != null) {
      String? upload = await ApiService.uploadImage(
        selectedImage!);
    if (upload != null) {
      namaFile = upload;
    }
  }

      var result = await ApiService.editPesanan(
        id: widget.pesanan.id ?? "",
        namaPelanggan: namaPelangganController.text,
        noHp: noHpController.text,
        alamat: alamatController.text,
        namaProduk: namaProdukController.text,
        tanggalPesan: DateFormat("yyyy-MM-dd").format(tanggalPesan),
        deadline: DateFormat("yyyy-MM-dd").format(deadline),
        harga: hargaController.text.replaceAll('.', ''),
        status: status,
        catatanUkuran: catatanUkuranController.text,
        catatanBiaya: catatanBiayaController.text,
        catatanTambahan: catatanTambahanController.text,
        foto: namaFile,
      );

      if (result["success"] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pesanan berhasil diperbarui"),
          ),
        );

        Navigator.pop(
          context,PesananModel(
            id: widget.pesanan.id,
            namaPelanggan: namaPelangganController.text,
            noHp: noHpController.text,
            alamat: alamatController.text,
            namaProduk: namaProdukController.text,
            tanggalPesan: DateFormat("yyyy-MM-dd").format(tanggalPesan),
            deadline: DateFormat("yyyy-MM-dd").format(deadline),
            harga: hargaController.text.replaceAll('.', ''),
            status: status,
            catatanUkuran: catatanUkuranController.text,
            catatanBiaya: catatanBiayaController.text,
            catatanTambahan: catatanTambahanController.text,
            foto: namaFile,
          ),
        );
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error : $e"),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget field({
  required String label,
  required TextEditingController controller,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: isLoading,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text("Edit Pesanan"),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Foto Referensi",
              style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              ),
             ),
            ),
     const SizedBox(height: 10),
    
    // ===== FOTO =====
      Card(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    child: Padding(
    padding: const EdgeInsets.all(15),
    child: Column(
      children: [

        // Preview Foto
        selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  selectedImage!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              )

            : widget.pesanan.foto != null &&
                    widget.pesanan.foto!.isNotEmpty

                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      "${Api.baseUrl}/uploads/${widget.pesanan.foto}",
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 70,
                          ),
                        );
                      },
                    ),
                  )

                : Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 70,
                    ),
                  ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : pilihGambar,
            icon: const Icon(Icons.photo_library),
            label: const Text(
              "Ganti Foto Referensi",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 20),

            field(
              label: "Nama Pelanggan",
              controller: namaPelangganController,
            ),

            field(
              label: "No HP",
              controller: noHpController,
            ),

            field(
              label: "Alamat",
              controller: alamatController,
              maxLines: 3,
            ),

            field(
              label: "Nama Produk",
              controller:
                  namaProdukController,
            ),

            Card(
              child: ListTile(
                title: const Text("Tanggal Pesan"),
                subtitle: Text(
                  DateFormat("dd MMM yyyy")
                      .format(tanggalPesan),
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: pilihTanggalPesan,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              child: ListTile(
                title: const Text("Deadline"),
                subtitle: Text(
                  DateFormat("dd MMM yyyy")
                      .format(deadline),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: pilihDeadline,
              ),
            ),
            const SizedBox(height: 15),

            field(
              label: "Harga",
              controller: hargaController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
            ),

            DropdownButtonFormField<String>(

              initialValue: status,
              decoration: InputDecoration(
                labelText: "Status",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              items: const [
                DropdownMenuItem(
                  value: "Pending",
                  child: Text("Pending"),
                ),

                DropdownMenuItem(
                  value: "Diproses",
                  child: Text("Diproses"),
                ),

                DropdownMenuItem(
                  value: "Selesai",
                  child: Text("Selesai"),
                ),
              ],

              onChanged: isLoading ? null : (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            const SizedBox(height: 15),

            field(
              label: "Catatan Ukuran",
              controller: catatanUkuranController,
              maxLines: 3,
            ),

            field(
              label: "Catatan Biaya",
              controller: catatanBiayaController,
              maxLines: 3,
            ),

            field(
              label: "Catatan Tambahan",
              controller: catatanTambahanController,
              maxLines: 4,
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                ),

                onPressed:
                    isLoading
                        ? null
                        : updateData,

                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )

                    : const Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
              ),

            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.parse(
      newValue.text.replaceAll('.', ''),
    );

    final newText =
        NumberFormat.decimalPattern('id').format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newText.length,
      ),
    );
  }
}