<?php
session_start();

require_once './database.inc.php';
require_once './Models/flights.model.php';
require_once './Models/tickets.model.php';

$price = isset($_GET['price']) ? $_GET['price'] : null;
$fid = isset($_GET['fid']) ? $_GET['fid'] : null;
$tids = isset($_GET['tids']) ?  $_GET['tids'] : [];;

$flightInfo = getFlightFromFid($fid);
$airline = getFlightAirline($fid);
 
/*
echo $airline;
echo "<br>";

print_r($flightInfo);
echo "<br>";

foreach($tids as $tid){
    echo $tid;
    echo "<br>";

    print_r(retrievePassenger(retrieveTicket($tid)["passportID"]));
    echo "<br>";
}

echo $price;
echo "<br>";
*/

?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }

        .chart-container {
            display: flex;
        }

        .info-box {
            border: 1px solid #ccc;
            padding: 10px;
            margin: 10px;
            max-width: 300px;
        }
    </style>
    <title>Flight Information Chart</title>
</head>
<body>
    <h1><?php echo $airline; ?></h1>
    <p><strong>Total Price:</strong> <?php echo $price; ?></p>
    <p><strong>Reservation ID:</strong> <?php echo retrieveTicket($tids[0])["rid"]; ?></p>

    <div class="chart-container">
        <div class="info-box">
            <h2>Flight Information</h2>
            <?php
            foreach ($flightInfo as $key => $value) {
                if ($key == 'registrationNumber' || $key == 'price'){
                    continue;
                }
                echo "<p><strong>$key:</strong> $value</p>";
            }
            ?>
        </div>

        <?php
        foreach ($tids as $tid) {
            $passengerInfo = retrievePassenger(retrieveTicket($tid)["passportID"]);
            ?>
            <div class="info-box">
                <h2>Passenger Information</h2>
                <p><strong>Ticket ID:</strong> <?php echo $tid; ?></p>
                <?php
                foreach ($passengerInfo as $key => $value) {
                    if ($key == 'fcid'){
                        continue;
                    }
                    echo "<p><strong>$key:</strong> $value</p>";
                }
                ?>
            </div>
            <?php
        }
        ?>
    </div>
</body>
</html>
