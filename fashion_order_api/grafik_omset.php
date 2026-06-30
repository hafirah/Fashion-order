<?php
header("Content-Type: application/json");
include "koneksi.php";

$data = [];

$query = mysqli_query($conn,"
SELECT
MONTH(tanggal_pesan) AS bulan,
SUM(harga) AS omset
FROM pesanan
WHERE status='Selesai'
GROUP BY MONTH(tanggal_pesan)
ORDER BY MONTH(tanggal_pesan)
");

$namaBulan = [
1=>"Jan",
2=>"Feb",
3=>"Mar",
4=>"Apr",
5=>"Mei",
6=>"Jun",
7=>"Jul",
8=>"Agu",
9=>"Sep",
10=>"Okt",
11=>"Nov",
12=>"Des"
];

while($row=mysqli_fetch_assoc($query)){

$data[]=[
"bulan"=>$namaBulan[$row["bulan"]],
"omset"=>(int)$row["omset"]
];

}

echo json_encode([
"success"=>true,
"data"=>$data
]);

?>