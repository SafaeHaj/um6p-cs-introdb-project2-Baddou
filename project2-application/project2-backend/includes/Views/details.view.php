<?php

require_once '../database.inc.php';
require_once '../Models/flights.model.php';
require_once '../Models/tickets.model.php';

$fid = isset($_GET['fid']) ? $_GET['fid'] : null;
$passengercount = isset($_GET['passengers']) ? $_GET['passengers'] : null;
$flightClass = isset($_GET['flightClass']) ? $_GET['flightClass'] : null;
$availableSeats = getAvailableSeats($fid)[$flightClass];
$flightInfo = getFlightFromFid($fid);

if ($passengercount > $availableSeats ){
    header("Location: ../../index.php?error=This flight is full");
    exit();
}

?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../../css/flightDetails.css">
    <title>Airnest: Book Your Flight</title>
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
    <main>
        <div class="flight-details">
            <div class="flight-title">
                <h2>Flight Details</h2>
                <p class="fid"><?php echo $fid ?></p>
            </div>
            <div class="depdest-time">
                <div>
                    <span class="intro">Departure:</span>
                    <span class="intro">Destination:</span>
                    <span class="intro">Time of departure:</span>
                    <span class="intro">Time of arrival:</span>
                    <span class="intro">Class:</span>
                </div>
                <div>
                    <span id="departure"><?php echo $flightInfo['departure'] ?></span>
                    <span id="destination"> <?php echo $flightInfo['destination'] ?> </span>
                    <span id="timeDeparture"> <?php echo $flightInfo['departureTime'] ?> </span>
                    <span id="timeDestination"> <?php echo $flightInfo['arrivalTime'] ?> </span>
                    <span id="class"> <?php echo $flightClass ?> </span>
                </div>
            </div>

            <p class="additional-info">
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Blanditiis impedit, ducimus laboriosam animi
                adipisci fuga incidunt aspernatur non, deserunt, rerum iste ullam. Perferendis unde aspernatur
                asperiores impedit, itaque sequi aperiam?Lorem ipsum dolor sit amet, consectetur adipisicing elit. Blanditiis impedit, ducimus laboriosam animi
                adipisci fuga incidunt aspernatur non, deserunt, rerum iste ullam. Perferendis unde aspernatur
                asperiores impedit, itaque sequi aperiam?
            </p>

            <div class="choose">
                <button class="search" id="back">Search other Flights</button>
                <button class="book" id="next">Book Now</button>
            </div>
        </div>
        <img src="../../assets/img/istambul.jpg">
    </main>

    <script> 
            btn = document.getElementById('next');
            btn.addEventListener('click', function () {
                window.location.href = `tickets.view.php?fid=<?php echo $fid; ?>&passengers=<?php echo $passengercount; ?>&flightClass=<?php echo $flightClass?>`;
            });
            btn = document.getElementById('back');
            btn.addEventListener('click', function () {
                window.location.href = `../../index.php`;
            });
    </script>
    <script src="../../js/logoutButton.js"></script>
</body>

</html>

