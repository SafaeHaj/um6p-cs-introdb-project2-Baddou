<?php 

function getFlightFromFid($fid){
    $sql = "SELECT * FROM Flight WHERE fid = '$fid'";
    $result = executeQuery($sql);
    return $result->fetch_assoc(); 
}

function searchFlights($departure, $destination, $departureTime) {
    $sql = "SELECT * FROM Flight WHERE departure = '$departure' AND destination = '$destination'";
    //$sql = "SELECT * FROM Flight WHERE departure = '$departure' AND destination = '$destination' AND departureTime >= '$departureTime'";
    //$sql = "SELECT * FROM Flight ORDER BY departureTime LIMIT 20";
    $result = executeQuery($sql);
    return $result->fetch_all(MYSQLI_ASSOC); 
}

function cancel_flight($fid){
    $sql = "CALL CancelFlight('$fid')";
    executeQuery($sql);
}

function getFlightAirline($fid) {
    $sql = "SELECT a.airline
            FROM Airplane a
            JOIN Flight f ON a.registrationNumber = f.registrationNumber
            WHERE f.fid = '$fid'";
    $result = executeQuery($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        return $row['airline'];
    } else {
        return "Airline not found";
    }
}


function insertFlight($departure, $destination, $departureTime, $arrivalTime, $registrationNumber, $price) {
    $sql = "INSERT INTO Flight (departure, destination, departureTime, arrivalTime, registrationNumber, price) 
            VALUES ('$departure', '$destination', '$departureTime', '$arrivalTime', '$registrationNumber', '$price')";
    executeQuery($sql);
}

function dropFlight($flightID) {
    $sql = "DELETE FROM Flight WHERE fid = '$flightID'";
    executeQuery($sql);
}


function getAvailableSeats($fid) {
    $sql = "SELECT am.economySeats, am.premiumEconomySeats, am.businessClassSeats, am.firstClassSeats
            FROM Airplane a
            JOIN AirplaneModel am ON a.model = am.model
            JOIN Flight f ON a.registrationNumber = f.registrationNumber
            WHERE f.fid = '$fid'";
    $modelResult = executeQuery($sql);
    
    if ($modelResult->num_rows > 0) {
        $model = $modelResult->fetch_assoc();

        $sql = "SELECT class, COUNT(*) as bookedSeats
                FROM Ticket
                WHERE fid = '$fid'
                GROUP BY class";
        $bookedSeatsResult = executeQuery($sql);

        $bookedSeats = array(
            'Y' => 0,
            'Y+' => 0,
            'J' => 0,
            'FC' => 0,
        );

        while ($row = $bookedSeatsResult->fetch_assoc()) {
            $bookedSeats[$row['class']] = $row['bookedSeats'];
        }

        $availableSeats = array(
            'economy' => $model['economySeats'] - $bookedSeats['Y'],
            'premiumEconomy' => $model['premiumEconomySeats'] - $bookedSeats['Y+'],
            'businessClass' => $model['businessClassSeats'] - $bookedSeats['J'],
            'firstClass' => $model['firstClassSeats'] - $bookedSeats['FC'],
        );        

        return $availableSeats;
    }

    return null;
}



?>