<?php
session_start();

$hideButtons = '';
$hideLogout = 'style="display:none;"';


if (isset($_SESSION['user_email'])) {
    $hideButtons = 'style="display:none;"';
    $hideLogout = ''; 
}


$auth = isset($_GET['error']) ? $_GET['error'] : null;
$hideauth = isset($_GET['error'])? '' : 'style="display:none;"';
?>


<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="./css/stylesheet.css">
    <link rel="stylesheet" href="./css/forms.css">

    <title>Airnest: Book Your Next Flight</title>
</head>

<body>
    <header>
        
        <div class="title-logo">
            <img src="./assets/img/airnest_logo.png">
            <div class="title">
                <h1>Airnest</h1>
                <p>One <span class=f-orange>search</span>, millions of <span class=f-orange>destinations</span></p>
            </div>
        </div>

        <div class="account">
            <button class="register orange" id="registration_btn" <?php echo $hideButtons; ?>>Sign Up</button>
            <button class="login darkblue" id="login_btn" <?php echo $hideButtons; ?>>Log in</button>
            <button class="logout orange" id="logout_btn" <?php echo $hideLogout; ?>>Logout</button>
        </div>

    </header>

    <div class="modal hidden">
        <div class="enter-account signup-form hidden">
            <form class="signup-form" id="signup-form" method="post" action="./includes/Controllers/signup.controller.php">
                <label for="firstName">Name</label>
                <div class="name">
                    <input type="text" id="firstName" name="firstName" placeholder="First Name" required>
                    <input type="text" id="lastName" name="lastName" placeholder="Last Name" required>
                </div>

                <label for="emailSignup">Email</label>
                <input type="email" id="emailSignup" name="email" placeholder="username@domain.com" required>

                <label for="passwordSignup">Password</label>
                <input type="password" id="passwordSignup" name="password" placeholder="8 to 16 characters"
                    minlength="8" maxlength="16" required>

                <label for="birthdate">Birthdate</label>
                <input type="date" id="birthdate" name="birthdate" required>

                <input class="orange" type="submit" value="Sign Up">
            </form>
        </div>
        <div class="enter-account login-form hidden">
            <form class="login-form" id="login-form" method="post"  action="./includes/Controllers/login.controller.php">
                <label for="emailLogin">Email</label>
                <input type="email" id="emailLogin" name="email" placeholder="username@domain.com" required>

                <label for="passwordLogin">Password</label>
                <input type="password" id="passwordLogin" name="password" placeholder="Enter password" required>

                <input class="darkblue" type="submit" value="Log In">
            </form>
        </div>
    </div>


    <form id="search-form" method="post" action="./includes/Views/flights.view.php">
        <div class="trip-specifics">
            <input required type="radio" id="oneway" name="tripType" value="oneway">
            <label id="onewayLabel" for="oneway"><span class=f-orange>One Way</span></label>

            <input required type="radio" id="return" name="tripType" value="return">
            <label id="returnLabel" for="return"><span class=f-orange>Return</span></label>

            <input type="number" id="numberAdults" name="numberAdults" min="1" value="1">
            <label id="adultsLabel" for="numberAdults"><span class=f-orange>Adults</span></label>

            <input type="number" id="numberChildren" name="numberChildren" min="0" value="0">
            <label id="childrenLabel" for="numberChildren"><span class=f-orange>Children</span></label>

            <div class="class-select">
                <select required id="flightClass" name="flightClass">
                    <option class="blue" value="">Class</option>
                    <option class="blue" value="economy">Economy</option>
                    <option class="blue" value="premiumEconomy">Premium Economy</option>
                    <option class="blue" value="businessClass">Business Class</option>
                    <option class="blue" value="firstClass">First Class</option>
                </select>
                <img class="caret" src="./assets/caret-down-outline.svg"></svg>
            </div>
        </div>
        <div class="main-searchbar">
            <div class="search-container">
                <input type="text" id="departure" name="departure" placeholder="Departure" autocomplete="off" required>
                <div id="departureResults" class="search-results"></div>
            </div>
            <div class="search-container">
                <input type="text" id="destination" name="destination" placeholder="Destination" autocomplete="off" required>
                <div id="destinationResults" class="search-results"></div>
            </div>
            <input type="date" id="departure-time" name="departureTime" required>
            <input type="date" id="return-time" name="returnTime">
            <input class="orange" type="submit" value="Search">
        </div>
    </form>


    <footer>
        <p>&copy; 2023 AirNest. Done for the Data Management I Project.</p>
        <button class="error red" <?php echo html_entity_decode($hideauth); ?>>  <?php echo $auth; ?>  </button>
    </footer>
</body>

<script src="./js/loginButtons.js"> </script>
<script src="./js/logoutButton.js"> </script>
<script src="./js/mainIndex.js"> </script>

</html>
