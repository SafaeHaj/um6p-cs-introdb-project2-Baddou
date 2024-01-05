
<?php
session_start();

require_once '../database.inc.php';
require_once '../Models/flights.model.php';
require_once '../Models/tickets.model.php';

$fid = isset($_GET['fid']) ? $_GET['fid'] : null;
$passengercount = isset($_GET['passengers']) ? $_GET['passengers'] : null;
$flightClass = isset($_GET['flightClass']) ? $_GET['flightClass'] : null;
$flightInfo = getFlightFromFid($fid);
$airline = getFlightAirline($fid);

?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../../css/forms.css">
    <link rel="stylesheet" href="../../css/reserveflight.css">
    <title>Airnest: Book Your Flight</title>
</head>

<body>
    <header>
        <div class="title-logo">
            <img src="../../assets/img/airnest_logo.png">
            <div class="title">
                <h1>Airnest</h1>
            </div>
        </div>
        <div class="account">
            <button class="register orange" id = "logout_btn">Log Out</button>
        </div>
    </header>
    <main>
        <section class="passenger-info">
            <div class="title">
                <h2>Passenger Information</h2>
                <button type="button" onclick="showForm()"><img src="../../assets/caret-down-outline.svg"></button>
            </div>
            <div class="hidden passenger-forms">

                <?php
                for ($i = 1; $i <= $passengercount; $i++) {
                    echo'<form class="passenger-information" method="post">
                    <label class="form-label" for="firstName">First Name</label>
                    <div class="name">
                        <input type="text" name="firstName" placeholder="First Name" required>
                        <input type="text" name="lastName" placeholder="Last Name" required>
                    </div>

                    <label for="phoneNumber">Phone Number</label>
                    <input type="tel" name="phoneNumber" pattern="[0-9]{10}" placeholder="1234567890" required>

                    <label for="passportId">Passport ID</label>
                    <input type="text" name="passportId" placeholder="ABC123456" required>

                    <label for="cin">CIN</label>
                    <input type="text" name="cin" placeholder="CIN123456" required>

                    <label for="birthdate">Birthdate</label>
                    <input type="date" name="birthdate" required>

                    <p id="show-fcid">Frequent Flyer? Enter fidelity card<img class="show-fcid"
                            src="../../assets/caret-down-outline.svg"></p>
                    <div class="hidden fcfield">
                        <select class="fidelityCardType" name="fidelityCardType">
                            <option value="None">None</option>
                            <option value="Gold">Gold</option>
                            <option value="Silver">Silver</option>
                            <option value="Explorer">Explorer</option>
                            <option value="Platinum">Platinum</option>
                        </select>
                        <label for="fcid">Code</label>
                        <input class="form-input" type="text" id="fcid" name="fcid">
                    </div>

                    <div class="choose">
                        <input class="save" type="submit" value="Save">
                        <input type="reset" value="Reset">
                    </div>
                </form>';
                }
                ?>


            </div>
            <div id="passenger-list">

            </div>

        </section>

        <section id="order">
            <div class="reservation-container">
                <h2>Reservation</h2>
                <div class="flight">
                    <div class="depdest-time">
                        <p class="depdest" id="departure"><?php echo $flightInfo['departure'] ?></p>
                        <p class="time"><?php echo $flightInfo['departureTime'] ?> </p>
                        <p class="depdest" id="destination"> <?php echo $flightInfo['destination'] ?> </p>
                        <p class="class"><?php echo $flightClass ?></p> 
                    </div>
                    <div class="airline">
                        <p><?php echo $airline ?></p>
                    </div>
                </div>
                <p id="price">0 $</p>
                <div class="choose">
                    <button id="cancel">Cancel</button>
                    <button id="confirm">Confirm</button>
                </div>
            </div>
        </section>
    </main>

</body>

<script>
        var fid = '<?php echo $fid ;?>';
        var boarding_class = '<?php echo $flightClass ;?>';
        var flight_price = <?php echo $flightInfo['price']; ?>;
</script>

<script src="../../js/logoutButton.js"></script>
<script src="../../js/ticketManager.js"></script>

</html>