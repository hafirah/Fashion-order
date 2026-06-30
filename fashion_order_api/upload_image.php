<?php
error_reporting(E_ALL);
ini_set('display_errors',1);
header("Content-Type: application/json");

if (!isset($_FILES['image'])) {
    echo json_encode([
        "success" => false,
        "message" => "Tidak ada file image",
        "files" => $_FILES,
        "post" => $_POST
    ]);
    exit;
}

$file = $_FILES['image'];

$filename = time() . "_" . basename($file['name']);

$target = __DIR__ . "/uploads/" . $filename;

if (move_uploaded_file($file['tmp_name'], $target)) {

    echo json_encode([
        "success" => true,
        "filename" => $filename
    ]);

} else {

    echo json_encode([
        "success" => false,
        "message" => "move_uploaded_file gagal",
        "tmp_name" => $file['tmp_name'],
        "target" => $target,
        "error" => error_get_last()
    ]);

}