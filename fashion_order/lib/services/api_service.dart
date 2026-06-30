import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fashion_order/services/api.dart';
import 'dart:io';

class ApiService {

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    var url = Uri.parse("${Api.baseUrl}/register.php");
    var response = await http.post(
      url,
      body: {
        "username": username,
        "email": email,
        "password": password,
      },
    );
    return jsonDecode(response.body);
  }
  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    var url = Uri.parse("${Api.baseUrl}/login.php");
    var response = await http.post(
      url,
      body: {
        "username": username,
        "password": password,
      },
    );
    
    return jsonDecode(response.body);
  }
  // ================= GET PESANAN =================
  static Future<List<dynamic>> getPesanan() async {
    var url = Uri.parse("${Api.baseUrl}/get_pesanan.php");
    var response = await http.get(url);
    return jsonDecode(response.body);
  }
  // ================= TAMBAH PESANAN =================
  static Future<Map<String, dynamic>> tambahPesanan({
    required String namaPelanggan,
    required String noHp,
    required String alamat,
    required String namaProduk,
    required String tanggalPesan,
    required String deadline,
    required String harga,
    required String status,
    required String catatanUkuran,
    required String catatanBiaya,
    required String catatanTambahan,
    required String foto,
  }) async {
    var url = Uri.parse("${Api.baseUrl}/tambah_pesanan.php");
    var response = await http.post(
      url,
      body: {
        "nama_pelanggan": namaPelanggan,
        "no_hp": noHp,
        "alamat": alamat,

        "nama_produk": namaProduk,

        "tanggal_pesan": tanggalPesan,
        "deadline": deadline,

        "harga": harga,

        "status": status,

        "catatan_ukuran": catatanUkuran,
        "catatan_biaya": catatanBiaya,
        "catatan_tambahan": catatanTambahan,
        "foto": foto,
      },
    );
    return jsonDecode(response.body);
  }
  // ================= EDIT PESANAN =================
  static Future<Map<String, dynamic>> editPesanan({
    required String id,
    required String namaPelanggan,
    required String noHp,
    required String alamat,
    required String namaProduk,
    required String tanggalPesan,
    required String deadline,
    required String harga,
    required String status,
    required String catatanUkuran,
    required String catatanBiaya,
    required String catatanTambahan,
    required String foto,
  }) async {
    
    var url = Uri.parse("${Api.baseUrl}/edit_pesanan.php");
    var response = await http.post(
      url,
      body: {
        "id": id,

        "nama_pelanggan": namaPelanggan,
        "no_hp": noHp,
        "alamat": alamat,

        "nama_produk": namaProduk,

        "tanggal_pesan": tanggalPesan,
        "deadline": deadline,

        "harga": harga,

        "status": status,

        "catatan_ukuran": catatanUkuran,
        "catatan_biaya": catatanBiaya,
        "catatan_tambahan": catatanTambahan,
        "foto": foto,
      },
    );
    return jsonDecode(response.body);
  }
  // ================= HAPUS PESANAN =================
  static Future<Map<String, dynamic>> hapusPesanan(
    String id,
  ) async {
    var url = Uri.parse("${Api.baseUrl}/hapus_pesanan.php");
    var response = await http.post(
      url,
      body: {
        "id": id,
      },
    );
    return jsonDecode(response.body);
  }
  // ================= DASHBOARD =================
  static Future<Map<String, dynamic>> dashboard() async {
    var url = Uri.parse("${Api.baseUrl}/dashboard.php");
    var response = await http.get(url);
    return jsonDecode(response.body);
  }
  // ================= OMSET =================
  static Future<Map<String, dynamic>> omset() async {
    var url = Uri.parse("${Api.baseUrl}/omset.php");
    var response = await http.get(url);
    return jsonDecode(response.body);
  }

    // ================= UPLOAD IMAGE =================
  static Future<String?> uploadImage(File imageFile) async {
  var request = http.MultipartRequest(
    "POST",
    Uri.parse("${Api.baseUrl}/upload_image.php"),
  );

  request.files.add(
    await http.MultipartFile.fromPath(
      "image",
      imageFile.path,
    ),
  );

  var response = await request.send();
  var body = await response.stream.bytesToString();

  print("=== UPLOAD RESPONSE ===");
  print(body);
  var data = jsonDecode(body);
  if (data["success"] == true) {
    return data["filename"];
  }
  return null;
}
}