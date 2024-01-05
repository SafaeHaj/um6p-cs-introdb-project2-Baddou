<?php
session_start();

require_once '../database.inc.php';
require_once '../Models/tickets.model.php'; 

$fid = isset($_GET['fid']) ? $_GET['fid'] : null;
$flightClass = isset($_GET['flightClass']) ? $_GET['flightClass'] : null;


if(isset($_POST)){
    $data = json_decode(file_get_contents('php://input'), true);
    $passengers = $data['passengers'];
    $response = array();

    if (count($passengers) == 0){
        exit();
    }

    $dateReservation = date('Y-m-d H:i:s'); 
    $email = $_SESSION['user_email']; 

    $rid = insertReservation($dateReservation, $email);
    $generatedTids = array();

    foreach ($passengers as $passenger) {
        $passportID = $passenger['passportId'];
        $cin = $passenger['cin'];
        $pbirthDate = $passenger['birthdate'];
        $phoneNumber = $passenger['phoneNumber'];
        $pfirstName = $passenger['firstName'];
        $plastName = $passenger['lastName'];
        $fcid = isset($passenger['fcid']) ? $passenger['fcid'] : null;
        $fctype = isset($passenger['fidelityCardType']) ? $passenger['fidelityCardType'] : null;
        
        $fcid = NULL; 
        $fctype = NULL;
        if ($fcid != null && $fctype != null){
            insertCard($fcid, $fctype);
        }
        $fctype = 'Gold';

        insertPassenger($passportID, $cin, $pbirthDate, $phoneNumber, $pfirstName, $plastName, $fcid);
        $tid = insertTicket($passportID, $rid, $fid, $fctype, $flightClass);
        $generatedTids[] = $tid;
    }

    $dateConfirmation = date('Y-m-d H:i:s'); 
    confirmReservation($rid, $dateConfirmation);

    $tidsQueryParam = implode('&', array_map(function ($tid) {
        return 'tids[]=' . urlencode($tid);
    }, $generatedTids));

    $response = array('success' => true, 'redirectUrl' => '../ticket.php?fid='.$fid. '&'  . $tidsQueryParam);
    echo json_encode($response);
    exit();

}

?>
