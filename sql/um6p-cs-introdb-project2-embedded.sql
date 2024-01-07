-- Insert user information into User_ table
INSERT INTO User_ (uemail, ufirstName, ulastName, ubirthDate, passwordHash) 
VALUES ('$email', '$firstName', '$lastName', '$birthDate', '$password');

-- Retrieve user information based on email
SELECT * FROM User_ WHERE uemail = '$email';

-- Retrieve flight information based on fid
SELECT * FROM Flight WHERE fid = '$fid';

-- Retrieve flights based on departure and destination
SELECT * FROM Flight WHERE departure = '$departure' AND destination = '$destination';

-- Retrieve flights based on departure, destination, and departure time
SELECT * FROM Flight WHERE departure = '$departure' AND destination = '$destination' AND departureTime >= '$departureTime';

-- Retrieve flights ordered by departure time, limit to 20 results
SELECT * FROM Flight ORDER BY departureTime LIMIT 20;

-- Call stored procedure to cancel a flight
CALL CancelFlight('$fid');

-- Retrieve airline information based on flight ID
SELECT a.airline
FROM Airplane a
JOIN Flight f ON a.registrationNumber = f.registrationNumber
WHERE f.fid = '$fid';

-- Insert flight information into Flight table
INSERT INTO Flight (departure, destination, departureTime, arrivalTime, registrationNumber, price) 
VALUES ('$departure', '$destination', '$departureTime', '$arrivalTime', '$registrationNumber', '$price');

-- Delete flight information based on flight ID
DELETE FROM Flight WHERE fid = '$flightID';

-- Retrieve available seats information based on flight ID
SELECT am.economySeats, am.premiumEconomySeats, am.businessClassSeats, am.firstClassSeats
FROM Airplane a
JOIN AirplaneModel am ON a.model = am.model
JOIN Flight f ON a.registrationNumber = f.registrationNumber
WHERE f.fid = '$fid';

-- Count booked seats by class for a specific flight
SELECT class, COUNT(*) as bookedSeats
FROM Ticket
WHERE fid = '$fid'
GROUP BY class;

-- Retrieve ticket information based on ticket ID
SELECT * FROM Ticket WHERE tid = '$tid';

-- Call stored procedure to add ticket to reservation
CALL AddTicketToReservation('$ticketId', '$passportID', '$rid', '$fid', '$fctype', '$class');

-- Delete ticket information based on ticket ID
DELETE FROM Ticket WHERE tid = '$tid';

-- Insert reservation information into Reservation table
INSERT INTO Reservation (rid, dateReservation, email) 
VALUES ('$rid', '$dateReservation', '$email');

-- Update reservation confirmation date based on reservation ID
UPDATE Reservation SET dateConfirmation = '$dateConfirmation' WHERE rid = '$rid';

-- Retrieve reservation information based on reservation ID
SELECT * FROM Reservation WHERE rid = '$rid';

-- Delete reservation information based on reservation ID
DELETE FROM Reservation WHERE rid = '$rid';

-- Count passenger cards based on flight class ID
SELECT COUNT(*) FROM PassengerCard WHERE fcid = '$fcid';

-- Insert passenger information into Passenger table
INSERT IGNORE INTO Passenger (passportID, cin, pbirthDate, phoneNumber, pfirstName, plastName, fcid) 
VALUES ('$passportID', '$cin', '$pbirthDate', '$phoneNumber', '$pfirstName', '$plastName', '$fcid');

-- Retrieve passenger information based on passport ID
SELECT * FROM Passenger WHERE passportID = '$passportID';

-- Delete passenger information based on passport ID
DELETE FROM Passenger WHERE passportID = '$passportID';

-- Call stored procedure to calculate ticket price
CALL CalculateTicketPrice('$flightClass', '$fcType', '$fid');
