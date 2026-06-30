<?php
header("Content-Type: application/json");
include "koneksi.php";

$id=$_POST['id'];

$query=mysqli_query(
$conn,
"DELETE FROM pesanan
WHERE id='$id'"
);

echo json_encode([
"success"=>$query
]);

?>