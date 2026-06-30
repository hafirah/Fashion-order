<?php

header("Content-Type: application/json");
include "koneksi.php";

$total = mysqli_num_rows(
    mysqli_query(
        $conn,
        "SELECT * FROM pesanan"
    )
);

$pending = mysqli_num_rows(
    mysqli_query(
        $conn,
        "SELECT * FROM pesanan
        WHERE status='Pending'"
    )
);

$diproses = mysqli_num_rows(
    mysqli_query(
        $conn,
        "SELECT * FROM pesanan
        WHERE status='Diproses'"
    )
);

$selesai = mysqli_num_rows(
    mysqli_query(
        $conn,
        "SELECT * FROM pesanan
        WHERE status='Selesai'"
    )
);


// =======================
// Omset bulan ini
// =======================

$bulan = date("m");
$tahun = date("Y");

$qOmset = mysqli_query(
    $conn,
    "SELECT SUM(harga) AS total
     FROM pesanan
     WHERE status='Selesai'
     AND MONTH(tanggal_pesan)='$bulan'
     AND YEAR(tanggal_pesan)='$tahun'"
);

$dOmset = mysqli_fetch_assoc($qOmset);

$omsetBulan = $dOmset["total"] ?? 0;


// =======================
// Deadline terdekat
// =======================

$qDeadline = mysqli_query(
    $conn,
    "SELECT
        nama_pelanggan,
        nama_produk,
        deadline
    FROM pesanan
    WHERE status!='Selesai'
    ORDER BY deadline ASC
    LIMIT 5"
);

$deadline = [];

while ($row = mysqli_fetch_assoc($qDeadline)) {

    $hari = floor(
        (strtotime($row["deadline"]) - strtotime(date("Y-m-d")))
        / 86400
    );

    if ($hari == 0) {
        $ket = "Hari Ini";
    } elseif ($hari == 1) {
        $ket = "Besok";
    } elseif ($hari > 1) {
        $ket = "H-$hari";
    } else {
        $ket = "Terlambat";
    }

    $deadline[] = [
        "nama_pelanggan" => $row["nama_pelanggan"],
        "nama_produk" => $row["nama_produk"],
        "keterangan" => $ket
    ];
}


// =======================
// Output JSON
// =======================

echo json_encode([

    "total" => $total,
    "pending" => $pending,
    "diproses" => $diproses,
    "selesai" => $selesai,
    "omset_bulan" => $omsetBulan,
    "deadline" => $deadline

]);

?>