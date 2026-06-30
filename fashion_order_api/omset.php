<?php
header("Content-Type: application/json");
include "koneksi.php";

// ======================
// TOTAL OMSET
// ======================

$total = 0;

$queryTotal = mysqli_query(
    $conn,
    "SELECT SUM(harga) AS total
     FROM pesanan
     WHERE status='Selesai'"
);

$dataTotal = mysqli_fetch_assoc($queryTotal);

$total = (int)($dataTotal["total"] ?? 0);

// ======================
// OMSET BULAN INI
// ======================

$bulan = $_GET['bulan'] ?? date("m");
$tahun = $_GET['tahun'] ?? date("Y");

$queryBulan = mysqli_query(
    $conn,
    "SELECT SUM(harga) AS total
     FROM pesanan
     WHERE status='Selesai'
     AND MONTH(tanggal_pesan)='$bulan'
     AND YEAR(tanggal_pesan)='$tahun'"
);

$dataBulan = mysqli_fetch_assoc($queryBulan);

$bulanIni = (int)($dataBulan["total"] ?? 0);

// ======================
// JUMLAH PESANAN SELESAI
// ======================

$queryJumlah = mysqli_query(
    $conn,
    "SELECT COUNT(*) AS jumlah
     FROM pesanan
     WHERE status='Selesai'"
);

$dataJumlah = mysqli_fetch_assoc($queryJumlah);

$jumlahSelesai = (int)($dataJumlah["jumlah"] ?? 0);

// ======================
// DATA LAPORAN EXPORT
// ======================

$laporan = [];

$queryLaporan = mysqli_query(
    $conn,
    "SELECT
        tanggal_pesan,
        nama_pelanggan,
        nama_produk,
        harga
     FROM pesanan
     WHERE status='Selesai'
     AND MONTH(tanggal_pesan)='$bulan'
     AND YEAR(tanggal_pesan)='$tahun'
     ORDER BY tanggal_pesan ASC"
);

while ($row = mysqli_fetch_assoc($queryLaporan)) {
    $laporan[] = $row;
}

// ======================
// DATA GRAFIK OMSET
// ======================

$grafik = [];

for ($i = 1; $i <= 12; $i++) {

    $namaBulan = date("M", mktime(0, 0, 0, $i, 1));

    $q = mysqli_query(
        $conn,
        "SELECT SUM(harga) AS total
         FROM pesanan
         WHERE status='Selesai'
         AND MONTH(tanggal_pesan)='$i'
         AND YEAR(tanggal_pesan)='$tahun'"
    );

    $r = mysqli_fetch_assoc($q);

    $grafik[] = [
        "bulan" => $namaBulan,
        "omset" => (int)($r["total"] ?? 0),
    ];
}

// ======================
// OUTPUT JSON
// ======================

echo json_encode([
    "success" => true,
    "total_omset" => $total,
    "omset_bulan" => $bulanIni,
    "jumlah_selesai" => $jumlahSelesai,
    "grafik" => $grafik,
    "laporan" => $laporan,

]);

?>