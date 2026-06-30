<?php
header("Content-Type: application/json");
include "koneksi.php";

$username = $_POST['username'];
$email = $_POST['email'];
$password = md5($_POST['password']);

$cek = mysqli_query(
$conn,
"SELECT * FROM users WHERE username='$username'"
);

if(mysqli_num_rows($cek)>0){

echo json_encode([
"success"=>false,
"message"=>"Username sudah ada"
]);

}else{

$query = mysqli_query(
$conn,
"INSERT INTO users(
username,
email,
password
)

VALUES(
'$username',
'$email',
'$password'
)"
);

echo json_encode([
"success"=>$query
]);

}

?>