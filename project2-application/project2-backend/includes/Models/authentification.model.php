<?php

function insertUser($email, $firstName, $lastName, $birthDate, $password) {
    $sql = "INSERT INTO User_ (uemail, ufirstName, ulastName, ubirthDate, passwordHash) 
            VALUES ('$email', '$firstName', '$lastName', '$birthDate', '$password')";
    executeQuery($sql);
}

function getUserByEmail($email) {
    $sql = "SELECT * FROM User_ WHERE uemail = '$email'";
    $result = executeQuery($sql);

    return $result->fetch_assoc();
}

?>