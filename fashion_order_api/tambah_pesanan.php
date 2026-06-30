<?php
header("Content-Type: application/json");
include "koneksi.php";
$nama_pelanggan = $_POST['nama_pelanggan'];
$no_hp = $_POST['no_hp'];
$alamat = $_POST['alamat'];
$nama_produk = $_POST['nama_produk'];
$tanggal_pesan = $_POST['tanggal_pesan'];
$deadline = $_POST['deadline'];
$harga = $_POST['harga'];
$status = $_POST['status'];
$catatan_ukuran = $_POST['catatan_ukuran'];
$catatan_biaya = $_POST['catatan_biaya'];
$catatan_tambahan = $_POST['catatan_tambahan'];

$foto = $_POST['foto'];

$query = mysqli_query(
$conn,
"INSERT INTO pesanan(
nama_pelanggan,
no_hp,
alamat,
nama_produk,
tanggal_pesan,
deadline,
harga,

status,
catatan_ukuran,
catatan_biaya,
catatan_tambahan,
foto_referensi
)

VALUES(
'$nama_pelanggan',
'$no_hp',
'$alamat',
'$nama_produk',
'$tanggal_pesan',
'$deadline',
'$harga',
'$status',
'$catatan_ukuran',
'$catatan_biaya',
'$catatan_tambahan',
'$foto'
)"
);

echo json_encode([
"success"=>$query
]);
?>