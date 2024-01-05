<?php 
session_start();

require_once '../database.inc.php';
require_once '../Models/authentification.model.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    $email = $_POST['email'];
    $firstName = $_POST['firstName'];
    $lastName = $_POST['lastName'];
    $birthDate = $_POST['birthdate'];
    $password = $_POST['password'];


    // Perform basic input validation
    if (empty($email) || empty($firstName) || empty($lastName) || empty($birthDate) || empty($password)) {
        header("Location: ../../index.php?error=missing%20fields");
        exit();
    }

    // Validate email format
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        header("Location: ../../index.php?error=invalid%20email");
        exit();
    }

    // Check if the email is already registered
    $existingUser = getUserByEmail($email);
    if ($existingUser) {
        header("Location: ../../index.php?error=email%20exists");
        exit();
    }


    insertUser($email, $firstName, $lastName, $birthDate, $password);
    $_SESSION['user_email'] = $email; 
    header("Location: ../../index.php");
    exit();
}

?>