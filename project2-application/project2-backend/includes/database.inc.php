<?php
$servername = "127.0.0.1:3306";
$username = "root";
$password = "avengetech7";
$database = "project2";

$conn = new mysqli($servername, $username, $password, $database);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}


function executeQuery($sql) {
    global $conn;

    $result = $conn->query($sql);

    if (!$result) {
        die("Error executing query: " . $conn->error);
    }

    return $result;
}

?>
