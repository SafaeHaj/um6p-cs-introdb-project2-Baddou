<?php

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    session_start();
    $_SESSION = array();
    session_destroy();
    header("Location: ../../index.php");
    exit();
}

?>
