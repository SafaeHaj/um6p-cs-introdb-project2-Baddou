USE Project2;

-- Retrieve upcoming flights with available seats in economy class:

SELECT
    Flight.fid,
    Flight.destination,
    Flight.departureTime,
    COUNT(Ticket.tid) AS bookedSeats,
    AirplaneModel.economySeats - COUNT(Ticket.tid) AS availableSeats
FROM Flight
LEFT JOIN Ticket ON Flight.fid = Ticket.fid
JOIN Airplane ON Flight.registrationNumber = Airplane.registrationNumber
JOIN AirplaneModel ON AirplaneModel.model = Airplane.model
WHERE DATEDIFF(Flight.departureTime, NOW()) > 0
GROUP BY Flight.fid, Flight.destination, Flight.departureTime, AirplaneModel.economySeats
HAVING availableSeats > 0
ORDER BY Flight.departureTime ASC;

-- Retrieve top 5 destinations based on the number of ticketss:
SELECT
    Flight.destination,
    COUNT(Ticket.tid) AS ticketCount
FROM Flight
LEFT JOIN Ticket ON Flight.fid = Ticket.fid
GROUP BY Flight.destination
ORDER BY ticketCount DESC
LIMIT 5;

-- Retrieve users who have made reservations for more than one destination:
SELECT
    User_.uemail,
    User_.ufirstName,
    User_.ulastName
FROM User_
JOIN Reservation ON User_.uemail = Reservation.email
JOIN Ticket ON Reservation.rid = Ticket.rid
JOIN Flight ON Ticket.fid = Flight.fid
GROUP BY User_.uemail, User_.ufirstName, User_.ulastName
HAVING COUNT(DISTINCT Flight.destination) > 1;

-- Retrieve Airlines that have the same departure and destination
SELECT
    Flight.fid,
    Flight.arrivalTime,
    Flight.departureTime,
    Flight.destination,
    Flight.departure,
    Airplane.registrationNumber,
    
    Airplane.airline
FROM
    Flight
JOIN
    Airplane ON Flight.registrationNumber = Airplane.registrationNumber
WHERE
    Airplane.airline = 'International Flying Service'
    AND Flight.destination = 'Tulsa International Airport'
    AND Flight.departure = 'Port Lincoln Airport'

UNION

SELECT
    Flight.fid,
    Flight.arrivalTime,
    Flight.departureTime,
    Flight.destination,
    Flight.departure,
    Airplane.registrationNumber,

    Airplane.airline
FROM
    Flight
JOIN
    Airplane ON Flight.registrationNumber = Airplane.registrationNumber

WHERE
    Airplane.airline = 'InteliJet Airways'
    AND Flight.destination = 'Tulsa International Airport'
    AND Flight.departure = 'Port Lincoln Airport';
    
-- Find Passenger Infos for a specific Reservation
SELECT    
	Reservation.email,
    Reservation.dateReservation,
    Reservation.dateConfirmation,
    Passenger.passportID,
    Passenger.cin,
    Passenger.pbirthDate,
    Passenger.phoneNumber,
    Passenger.pfirstName,
    Passenger.plastName,
    Ticket.tid,
    Ticket.seatNumber,
    Ticket.class,
    Ticket.price,
    Ticket.passportID AS ticketPassportID,
    Ticket.fid,
    Ticket.fctype
FROM
    Reservation
    JOIN Ticket ON Reservation.rid = Ticket.rid
    JOIN Passenger ON Passenger.passportID = Ticket.passportID
    WHERE Reservation.rid = '10';
  
    
-- Reserach-bar-like query for Flight
SELECT arrivalTime, departureTime, fid, registrationNumber FROM Flight
WHERE Flight.destination = 'Ibn Batouta Airport'
		AND Flight.departure = 'Henderson Executive Airport';
            
-- Infos about Flight from Airline and Model 
SELECT Flight.fid,
    Flight.arrivalTime,
    Flight.departureTime,
    Flight.destination,
    Flight.departure, 
    Airplane.model,
    Airplane.Airline
FROM
	Flight 
JOIN Airplane ON Flight.registrationNumber = Airplane.registrationNumber

WHERE Airplane.Airline = 'Japan Airlines'
OR Airplane.model = 'CRJ9';


-- Retrieve 5 flights with the biggest luggage weight for a passenger
SELECT Flight.fid,
    Flight.arrivalTime,
    Flight.departureTime,
    Flight.destination,
    Flight.departure,
    AirplaneModel.maxweight
FROM Flight
JOIN Airplane ON Airplane.registrationNumber = Flight.registrationNumber
JOIN AirplaneModel ON AirplaneModel.model = Airplane.model

ORDER BY AirplaneModel.maxweight DESC
LIMIT 5;
 
 -- Total Price of a given reservation
 SELECT R.rid AS ReservationID,
		R.email,
		SUM(T.price) AS TotalTicketPrice
FROM Reservation R
INNER JOIN Ticket T ON R.rid = T.rid
WHERE R.rid = '100'
GROUP BY R.rid;

-- Passengers in a specific flight
SELECT 
	Passenger.passportID,
    Passenger.pfirstName,
    Passenger.plastName,
    Flight.fid
FROM Passenger
JOIN Ticket ON Passenger.passportID = Ticket.passportID
JOIN Flight ON Ticket.fid = Flight.fid
WHERE Flight.fid = 'OP340';
