<?php

$conn = mysqli_connect(
    "localhost",
    "root",
    "",
    "fashion_order"
);

if (!$conn) {
    die(mysqli_connect_error());
}