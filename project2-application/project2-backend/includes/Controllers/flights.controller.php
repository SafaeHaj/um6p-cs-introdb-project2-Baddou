<?php

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve form data
    $numberAdults = $_POST['numberAdults'];
    $numberChildren = $_POST['numberChildren'];
    $departure = $_POST['departure'];
    $destination = $_POST['destination'];
    $departureTime = $_POST['departureTime'];
    $flightClass = $_POST['flightClass'];

    if ($numberAdults == 0){
        header('Location: ../../index.php?error=You cant reserve without adults');
        exit();
    }


    $returnTime = isset($_POST['returnTime']) ? $_POST['returnTime'] : null;
    $tripType = 1; // $_POST['tripType'];

    $flights = searchFlights($departure, $destination, $departureTime);
    foreach ($flights as &$flight) {
        $airlineName = getFlightAirline($flight['fid']);
        $flight['airline'] = $airlineName;
        $flight['seats_left'] = getAvailableSeats($flight['fid'])[$flightClass];

    }    
    $jsonData = json_encode($flights);
}

?>
