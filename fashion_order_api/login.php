<?php
header("Content-Type: application/json");
include "koneksi.php";
$username = $_POST['username'];
$password = md5($_POST['password']);
$query = mysqli_query(
$conn,
"SELECT * FROM users
WHERE username='$username'
AND password='$password'"
);
$data = mysqli_fetch_assoc($query);
if($data){
echo json_encode([
"success"=>true,
"data"=>$data
]);
}else{
echo json_encode([
"success"=>false
]);
}
?>