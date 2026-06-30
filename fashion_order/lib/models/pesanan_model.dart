class PesananModel {

  String? id;
  String? namaPelanggan;
  String? noHp;
  String? alamat;
  String? namaProduk;

  String? tanggalPesan;
  String? deadline;

  String? harga;

  String? status;

  String? catatanUkuran;
  String? catatanBiaya;
  String? catatanTambahan;

  String? foto;

  PesananModel({

    this.id,
    this.namaPelanggan,
    this.noHp,
    this.alamat,
    this.namaProduk,
    this.tanggalPesan,
    this.deadline,
    this.harga,
    this.status,
    this.catatanUkuran,
    this.catatanBiaya,
    this.catatanTambahan,
    this.foto

  });
  factory PesananModel.fromJson(Map<String,dynamic> json){
    return PesananModel(
      id: json['id'],
      namaPelanggan: json['nama_pelanggan'],
      noHp: json['no_hp'],
      alamat: json['alamat'],
      namaProduk: json['nama_produk'],
      tanggalPesan: json['tanggal_pesan'],
      deadline: json['deadline'],
      harga: json['harga'],
      status: json['status'],
      catatanUkuran: json['catatan_ukuran'],
      catatanBiaya: json['catatan_biaya'],
      catatanTambahan: json['catatan_tambahan'],
      foto: json['foto_referensi'],
    );
  }
}