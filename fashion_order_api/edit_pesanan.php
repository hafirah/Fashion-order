<?php
header("Content-Type: application/json");
include "koneksi.php";
$id = $_POST['id'];

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

    "UPDATE pesanan SET

    nama_pelanggan='$nama_pelanggan',
    no_hp='$no_hp',
    alamat='$alamat',

    nama_produk='$nama_produk',

    tanggal_pesan='$tanggal_pesan',
    deadline='$deadline',

    harga='$harga',

    status='$status',

    catatan_ukuran='$catatan_ukuran',
    catatan_biaya='$catatan_biaya',
    catatan_tambahan='$catatan_tambahan',

    foto_referensi='$foto'

    WHERE id='$id'"
);

echo json_encode([
    "success" => $query
]);

?>