<?php

session_start();

if (!isset($_SESSION['user_email'])) {
    header('Location: ../../index.php?error=You%20need%20to%20be%20logged%20in');
}


require_once '../database.inc.php';
require_once '../Models/flights.model.php';
require_once '../Controllers/flights.controller.php';
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../../css/resultspage.css">
    <title>Airnest: Results Page</title>
</head>

<body>
    <header>
        <div class="title-logo">
            <img src="../../assets/img/airnest_logo.png">
            <div class="title">
                <h1>Airnest</h1>
                <p>One <span class=f-orange>search</span>, millions of <span class=f-orange>destinations</span></p>
            </div>
        </div>

        <div class="account">
            <button class="register orange" id="logout_btn">Log Out</button>
        </div>
    </header>

    <main class="flightContainer" id="bigContainer">
        <h2>Search Results:</h2>

    </main>



    <script>
        var boarding_class = '<?php echo $flightClass ;?>';
        var passenger_count = <?php echo (string) ($numberAdults + $numberChildren); ?>;
        var flightsData = <?php echo $jsonData; ?>;
    </script>

    <script src="../../js/flightResultDisplayer.js"></script>
    <script src="../../js/logoutButton.js"></script>

</body>

</html>