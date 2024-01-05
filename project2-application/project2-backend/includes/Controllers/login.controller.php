<?php 
session_start();

require_once '../database.inc.php';
require_once '../Models/authentification.model.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST['email'];
    $password = $_POST['password'];

    // Perform basic input validation
    if (empty($email) || empty($password)) {
        header("Location: ../../index.php?error=missing%20fields");
        exit();
    }

    $user = getUserByEmail($email);

    // Check if the user exists
    if (!$user) {
        header("Location: ../../index.php?error=user%20not%20found");
        exit();
    }

    // Verify the password
    if ( !($password == $user['passwordHash']) ) {
        header("Location: ../../index.php?error=incorrect%20password");
        exit();
    }

    $_SESSION['user_email'] = $email; 
    header("Location: ../../index.php");
    exit();
}
?>
