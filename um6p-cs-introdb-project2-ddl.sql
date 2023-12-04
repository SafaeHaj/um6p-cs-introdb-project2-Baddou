DROP DATABASE IF EXISTS Project2;
CREATE DATABASE Project2;
USE Project2;

CREATE TABLE User_ (
    uemail VARCHAR(20) NOT NULL,
    ufirstName VARCHAR(20) NOT NULL,
    ulastName VARCHAR(20) NOT NULL,
    ubirthDate DATE NOT NULL ,
    passwordHash VARCHAR(64) NOT NULL,
    PRIMARY KEY (uemail)
);

CREATE TABLE Passenger(
    cin VARCHAR(20) NOT NULL,
    pbirthDate DATE NOT NULL,
    passportID VARCHAR(20) NOT NULL,
    phoneNumber VARCHAR(20),
    pfirstName VARCHAR(20) NOT NULL,
    plastName VARCHAR(20) NOT NULL,
    fcid VARCHAR(20),
    PRIMARY KEY (passportID),
    FOREIGN KEY (fcid) REFERENCES PassengerCard(fcid)
);

CREATE TABLE PassengerCard(
    fctype VARCHAR(20) NOT NULL,
    fcid VARCHAR(20) NOT NULL,
    PRIMARY KEY (fcid),
    FOREIGN KEY (fctype) REFERENCES FidelityCard(fctype),
    FOREIGN KEY (fcid) REFERENCES Passenger(fcid)
);

CREATE TABLE Reservation (
    rid VARCHAR(20) NOT NULL,
    dateReservation DATETIME NOT NULL,
    dateConfirmation DATETIME NOT NULL,
    email VARCHAR(20) NOT NULL,
    PRIMARY KEY (rid),
    FOREIGN KEY (email) REFERENCES User_(uemail),
    CHECK (dateReservation < dateConfirmation),
    CHECK (DATEDIFF(dateConfirmation, dateReservation) <= 1)
);

CREATE TABLE Ticket(
    tid VARCHAR(20) NOT NULL,
    seatNumber INT UNIQUE,
    price FLOAT NOT NULL,
    passportID VARCHAR(20) NOT NULL,
    rid VARCHAR(20) NOT NULL,
    fid VARCHAR(20) NOT NULL,
    fctype VARCHAR(20) NOT NULL,
    PRIMARY KEY (ticketID),
    FOREIGN KEY (fctype) REFERENCES FidelityCard(fctype),
    FOREIGN KEY (passportID) REFERENCES Passenger(passportID),
    FOREIGN KEY (rid) REFERENCES Reservation(rid),
    FOREIGN KEY (fid) REFERENCES Flight(fid)
);

CREATE TABLE FidelityCard(
    fctype VARCHAR(20) NOT NULL,
    reduction INT NOT NULL,
    PRIMARY KEY (fctype),
    CONSTRAINT check_reduction CHECK (reduction < 70)
);

CREATE TABLE Flight(
    fid VARCHAR(20) NOT NULL,
    arrivalTime DATETIME NOT NULL,
    departureTime DATETIME NOT NULL,
    destination VARCHAR(20) NOT NULL,
    departure VARCHAR(20) NOT NULL,
    registrationNumber INT NOT NULL,
    PRIMARY KEY (fid),
    FOREIGN KEY (registrationNumber) REFERENCES Airplane(registrationNumber)
);

CREATE TABLE AirplaneModel(
    model VARCHAR(20),
    economySeats INT,
    premiumEconomySeats INT,
    businessClassSeats INT,
    firstClassSeats INT,
    maxWeight INT,
    PRIMARY KEY (model)
);

CREATE TABLE Airplane(
    registrationNumber INT not null auto_increment,
    airline VARCHAR(20) NOT NULL,
    model VARCHAR(20) NOT NULL,
    PRIMARY KEY (registrationNumber)
);

CREATE TABLE Checks(
    email VARCHAR(20) NOT NULL,
    fid VARCHAR(20) NOT NULL,
    PRIMARY KEY (email, fid),
    FOREIGN KEY (email) REFERENCES User_(uemail),
    FOREIGN KEY (fid) REFERENCES Flight(fid)
);

-- EXPLANATORY COMMENT
CREATE INDEX uchecks
ON Checks(email);

CREATE INDEX fticket
ON Ticket(fid);

CREATE INDEX ureservation
ON Reservation(email);

CREATE INDEX dep_dest
ON Flight(departure, destination, departureTime);

CREATE INDEX airline_airplane
ON Airplane(airline);

-- EXPLANATORY COMMENT
DELIMITER //
CREATE TRIGGER checkValidReservation
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
    DECLARE adult_count INT;

    SELECT COUNT(*) INTO adult_count
    FROM Ticket
    INNER JOIN Passenger ON Ticket.passportID = Passenger.passportID
    WHERE Ticket.rid = NEW.rid AND YEAR(CURDATE()) - YEAR(Passenger.pbirthDate) >= 16;

    IF adult_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reservation refused. No accompanying adult is registered.';
    END IF;
END;
//

-- EXPLANATORY COMMENT
DELIMITER //
CREATE TRIGGER user_age_check BEFORE INSERT ON User_
FOR EACH ROW
BEGIN
    IF DATEDIFF(NOW(), NEW.ubirthDate) < 6570 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User must be 18 years or older.';
    END IF;
END;
//

-- EXPLANATORY COMMENT
DELIMITER //
CREATE TRIGGER reservations_date_check BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
    IF DATEDIFF(NOW(), NEW.dateConfirmation) >= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Date of reservation is not valid';
    END IF;
END;
//



    
