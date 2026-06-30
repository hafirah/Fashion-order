import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class TambahPesananPage extends StatefulWidget {
  const TambahPesananPage({super.key});

  @override
  State<TambahPesananPage> createState() =>
      _TambahPesananPageState();
}

class _TambahPesananPageState
  extends State<TambahPesananPage> {
    
  final namaPelangganController = TextEditingController();
  final noHpController = TextEditingController();
  final alamatController = TextEditingController();
  final namaProdukController = TextEditingController();
  final hargaController = TextEditingController();
  final catatanUkuranController = TextEditingController();
  final catatanBiayaController = TextEditingController();
  final catatanTambahanController = TextEditingController();

  bool isLoading = false;
  File? selectedImage;
  String status = "Pending";
  DateTime tanggalPesan = DateTime.now();
  DateTime deadline =
      DateTime.now().add(
    const Duration(days: 7),
  );

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

  Future<void> pilihFoto() async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
  );
  if (image != null) {
    setState(() {
      selectedImage = File(image.path);
    });
  }
}

 Future<void> simpan() async {
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
    String namaFile = "";
    if (selectedImage != null) {
      String? uploadResult = await ApiService.uploadImage(
        selectedImage!,
      );
      if (uploadResult != null) {
        namaFile = uploadResult;
      }
    }
    var result = await ApiService.tambahPesanan(
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
          content: Text("Pesanan berhasil disimpan"),
        ),
      );

      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal menyimpan data",
          ),
        ),
      );
    }

  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Error : $e",
        ),
      ),
    );
  }
  setState(() {
    isLoading = false;
  });
}

  Widget buildTextField({
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
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
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
        title: const Text("Tambah Pesanan"),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField(
              label: "Nama Pelanggan",
              controller: namaPelangganController,
            ),
            buildTextField(
              label: "No HP",
              controller: noHpController,
              keyboardType: TextInputType.phone,
            ),
            buildTextField(
              label: "Alamat",
              controller: alamatController,
              maxLines: 3,
            ),
            buildTextField(
              label: "Nama Produk",
              controller: namaProdukController,
            ),
            Card(
              child: ListTile(
                title: const Text(
                  "Tanggal Pesan",
                ),
                subtitle: Text(
                  DateFormat(
                    "dd MMM yyyy",
                  ).format(
                    tanggalPesan,
                  ),
                ),
                trailing: const Icon(
                  Icons.calendar_month,
                ),
                onTap:
                    pilihTanggalPesan,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              child: ListTile(
                title: const Text(
                  "Deadline",
                ),

                subtitle: Text(
                  DateFormat(
                    "dd MMM yyyy",
                  ).format(
                    deadline,
                  ),
                ),

                trailing: const Icon(
                  Icons.calendar_today,
                ),

                onTap:
                    pilihDeadline,
              ),
            ),
            const SizedBox(height: 15),

          buildTextField(
            label: "Harga",
            controller: hargaController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
          ),

            DropdownButtonFormField(
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
                  child: Text(
                    "Pending",
                  ),
                ),

                DropdownMenuItem(
                  value: "Diproses",
                  child: Text(
                    "Diproses",
                  ),
                ),

                DropdownMenuItem(
                  value: "Selesai",
                  child: Text(
                    "Selesai",
                  ),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  status = value.toString();
                });
              },
            ),
            const SizedBox(height: 15),

            buildTextField(
              label: "Catatan Ukuran",
              controller: catatanUkuranController,
              maxLines: 3,
            ),

            buildTextField(
              label: "Catatan Biaya",
              controller: catatanBiayaController,
              maxLines: 3,
            ),

            buildTextField(
              label: "Catatan Tambahan",
              controller: catatanTambahanController,
              maxLines: 4,
            ),
            const SizedBox(height: 20),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: pilihFoto,
          icon: const Icon(Icons.image),
          label: const Text("Pilih Foto Referensi"),
        ),
      ],
    ),
  ),
),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                ),
                onPressed: isLoading ? null : simpan,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color:Colors.white,
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(
                          color:Colors.white,
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
