import 'package:flutter/material.dart';
import 'package:fashion_order/models/pesanan_model.dart';
import 'package:fashion_order/services/api_service.dart';
import 'package:fashion_order/theme.dart';
import 'detail_pesanan_page.dart';
import 'tambah_pesanan_page.dart';
import 'package:fashion_order/services/api.dart';
import 'package:intl/intl.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}
class _PesananPageState extends State<PesananPage> {
  List<PesananModel> pesananList = [];
  List<PesananModel> filteredList = [];
  bool isLoading = true;

  final TextEditingController searchController =
      TextEditingController();
  String selectedStatus = "Semua";

  final tanggalFormat = DateFormat(
  "dd MMM yyyy",
  "id",
);

  final rupiah = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    getData();
  }
  Future<void> getData() async {
    try {
      var result =
          await ApiService.getPesanan();

      pesananList = result
          .map<PesananModel>(
            (e) =>
                PesananModel.fromJson(e),
          )
          .toList();

      filterData();

    } catch (e) {

      debugPrint(e.toString());

    }
    setState(() {
      isLoading = false;
    });

  }
  void filterData() {
    List<PesananModel> data =
        List.from(pesananList);
    if (selectedStatus != "Semua") {
      data = data.where((item) {
        return item.status ==
            selectedStatus;
      }).toList();
    }
    if (searchController.text.isNotEmpty) {

      data = data.where((item) {

        final nama =
            item.namaPelanggan
                    ?.toLowerCase() ??
                "";

        final produk =
            item.namaProduk
                    ?.toLowerCase() ??
                "";

        return nama.contains(
                searchController.text
                    .toLowerCase()) ||
            produk.contains(
                searchController.text
                    .toLowerCase());

      }).toList();

    }

    setState(() {
      filteredList = data;
    });

  }

  Future<void> hapusData(
      String id) async {

    var result =
        await ApiService.hapusPesanan(id);

    if (result["success"] == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Pesanan berhasil dihapus"),
        ),
      );
      getData();
    }
  }

  void dialogHapus(String id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text("Hapus Pesanan"),
          content: const Text(
              "Yakin ingin menghapus pesanan ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await hapusData(id);
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
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

  Color deadlineColor(DateTime deadline) {
  final sekarang = DateTime.now();

  final today = DateTime(
    sekarang.year,
    sekarang.month,
    sekarang.day,
  );

  final target = DateTime(
    deadline.year,
    deadline.month,
    deadline.day,
  );

  final selisih = target.difference(today).inDays;

  if (selisih < 0) {
    return Colors.red;
  }

  if (selisih <= 3) {
    return Colors.orange;
  }

  return Colors.green;
}

String deadlineStatus(DateTime deadline) {
  final sekarang = DateTime.now();
  final today = DateTime(
    sekarang.year,
    sekarang.month,
    sekarang.day,
  );
  final target = DateTime(
    deadline.year,
    deadline.month,
    deadline.day,
  );
  final selisih = target.difference(today).inDays;
  
  if (selisih < 0) {
    return "Terlambat ${selisih.abs()} hari";
  }
  if (selisih == 0) {
    return "Deadline Hari Ini";
  }
  if (selisih == 1) {
    return "Besok";
  }
  if (selisih <= 3) {
    return "H-$selisih";
  }
  return "Masih $selisih hari";
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColor.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: getData,
              child: Column(
                children: [

  //================ SEARCH =================
  Padding(
    padding: const EdgeInsets.fromLTRB(
      15,
      15,
      15,
      10,
    ),
    child: TextField(
      controller: searchController,
      onChanged: (value) {
        filterData();
        },
        decoration: InputDecoration(
          hintText: "Cari pelanggan atau produk...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              15,
              ),
              borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
               
  //================ FILTER =================
  SizedBox(
    height: 50,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        ),
        children: [
          buildFilterChip("Semua"),
          buildFilterChip("Pending"),
          buildFilterChip("Diproses"),
          buildFilterChip("Selesai")
          ],
        ),
      ),
      const SizedBox(height: 8),

  //================ LIST =================
   Expanded(
    child: filteredList.isEmpty ? const Center(
      child: Text("Tidak ada data"),
    )
      : ListView.builder(
        padding: const EdgeInsets.only(
          bottom: 90,
        ),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final data = filteredList[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(
               horizontal: 15,
               vertical: 7,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  18,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  18,
                ),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(
                    builder: (_) => DetailPesananPage(
                      pesanan: data,
                    ),
                  ),
                ).then(
                  (_) => getData(),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(
                  15,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: data.foto != null &&
                        data.foto!.isNotEmpty
                        ? Image.network(
                          "${Api.baseUrl}/uploads/${data.foto}",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image,
                              ),
                            );
                          },
                        )
                        : Container(
                           width: 60,
                           height: 60,
                           decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text("${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(
                    width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.namaPelanggan ?? "",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(
                           height: 4),
                       Text(
                        data.namaProduk ?? "",
                        style: TextStyle( 
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    
                    const SizedBox(height: 5),

                  Text(
                    "Rp ${rupiah.format(int.tryParse(data.harga ?? "0") ?? 0)}",
                      style: const TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  
                  const SizedBox(height: 10),
                
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey,
                      ),
                    
                    const SizedBox(width: 6),
                  
                  Expanded(
                    child: Text(
                      tanggalFormat.format(
                        DateTime.parse(data.deadline!),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                     horizontal: 8,
                     vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: deadlineColor(
                         DateTime.parse(data.deadline!),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                     deadlineStatus(
                       DateTime.parse(data.deadline!),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        
                      Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal:10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor( data.status ?? "",
                          ),
                          borderRadius: BorderRadius.circular( 
                            20,
                          ),
                        ),
                        child: Text( data.status ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            PopupMenuButton(
              onSelected: (value) {
                if (value == "hapus") {
                  dialogHapus( data.id ?? "",
                );
              }
            },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: "hapus",
              child: Text("Hapus"),
            ),
            ],
            ),
          ],
          ),
          ),
        ),
        );
        },
      ),
      ),
      ],
    ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: AppColor.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text("Tambah"),
      onPressed: () {
        Navigator.push(context,
         MaterialPageRoute(
          builder: (_) => const TambahPesananPage(),
        ),
      ).then(
        (_) => getData(),
      );
      },
    ),
    );
  }

  //================ FILTER CHIP =================
  Widget buildFilterChip(String status) {
    final bool aktif =
        selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
      ),
      child: ChoiceChip(
        label: Text(status),
        selected: aktif,
        selectedColor: AppColor.primary,
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(
          color: aktif
              ? Colors.white
              : Colors.black87,
          fontWeight:
              FontWeight.w600,
        ),
        onSelected: (_) {
          setState(() {
            selectedStatus =
                status;
          });
          filterData();
        },
      ),
    );
  }
}