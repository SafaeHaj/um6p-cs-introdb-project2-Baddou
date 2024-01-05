<?php
function retrieveTicket($tid) {
    $sql = "SELECT * FROM Ticket WHERE tid = '$tid'";
    $result = executeQuery($sql);
    return $result->fetch_assoc();
}

function generateTicketId() {
    $prefix = 'T';
    $uniqueId = uniqid();
    $ticketId = $prefix . $uniqueId;
    return $ticketId;
}

function generateReservationId() {
    $prefix = 'R';
    $uniqueId = uniqid();
    $ticketId = $prefix . $uniqueId;
    return $ticketId;
}


function insertTicket($passportID, $rid, $fid, $fctype, $class) {
    $ticketId = generateTicketId();
    $sql = "CALL AddTicketToReservation('$ticketId', '$passportID', '$rid', '$fid', '$fctype', '$class')";
    executeQuery($sql);
    return $ticketId;
}

function cancelTicket($tid) {
    $sql = "DELETE FROM Ticket WHERE tid = '$tid'";
    executeQuery($sql);
}

function insertReservation($dateReservation, $email) {
    $rid = generateReservationId();
    $sql = "INSERT INTO Reservation (rid, dateReservation, email) 
            VALUES ('$rid', '$dateReservation', '$email')";
    executeQuery($sql);
    return $rid;
}

function confirmReservation($rid, $dateConfirmation) {
    $sql = "UPDATE Reservation SET dateConfirmation = '$dateConfirmation' WHERE rid = '$rid'";
    executeQuery($sql);
}

function retrieveReservation($rid) {
    $sql = "SELECT * FROM Reservation WHERE rid = '$rid'";
    $result = executeQuery($sql);
    return $result->fetch_assoc();
}

function cancelReservation($rid) {
    $sql = "DELETE FROM Reservation WHERE rid = '$rid'";
    executeQuery($sql);
}

function insertPassenger($passportID, $cin, $pbirthDate, $phoneNumber, $pfirstName, $plastName, $fcid) {
    $fcidExistsQuery = "SELECT COUNT(*) FROM PassengerCard WHERE fcid = '$fcid'";
    $fcidExistsResult = executeQuery($fcidExistsQuery);
    $fcidExists = $fcidExistsResult->fetch_assoc()['COUNT(*)'];
    $fcid = ($fcidExists > 0) ? "'$fcid'" : 'NULL';

    $sql = "INSERT IGNORE INTO Passenger (passportID, cin, pbirthDate, phoneNumber, pfirstName, plastName, fcid) 
            VALUES ('$passportID', '$cin', '$pbirthDate', '$phoneNumber', '$pfirstName', '$plastName', $fcid)";
    executeQuery($sql);
}


function retrievePassenger($passportID) {
    $sql = "SELECT * FROM Passenger WHERE passportID = '$passportID'";
    $result = executeQuery($sql);
    return $result->fetch_assoc();
}

function dropPassenger($passportID) {
    $sql = "DELETE FROM Passenger WHERE passportID = '$passportID'";
    executeQuery($sql);
}

// PROCEDURE exist

function getReductionPrice($flightClass, $fcType, $fid){
    $sql = "CALL CalculateTicketPrice('$flightClass', '$fcType', '$fid')";
    $result = executeQuery($sql);
    $price = $result['TicketPrice'];

    return $price;
}

?>