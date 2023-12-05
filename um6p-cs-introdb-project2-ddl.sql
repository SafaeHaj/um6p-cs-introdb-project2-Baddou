DROP DATABASE IF EXISTS Project2;
CREATE DATABASE Project2;
USE Project2;


CREATE TABLE User_ (
    uemail VARCHAR(32) NOT NULL,
    ufirstName VARCHAR(32) NOT NULL,
    ulastName VARCHAR(32) NOT NULL,
    ubirthDate DATE NOT NULL ,
    passwordHash VARCHAR(64) NOT NULL,
    PRIMARY KEY (uemail)
);

CREATE TABLE AirplaneModel(
    model VARCHAR(20),
    economySeats INT,
    premiumEconomySeats INT,
    businessClassSeats INT,
    firstClassSeats INT,
    maxweight INT,
    PRIMARY KEY (model)
);

CREATE TABLE Airplane(
    registrationNumber INT AUTO_INCREMENT,
    airline VARCHAR(64) NOT NULL,
    model VARCHAR(20) NOT NULL,
    PRIMARY KEY (registrationNumber),
    FOREIGN KEY (model) REFERENCES AirplaneModel(model) ON DELETE NO ACTION
    ON UPDATE CASCADE
);

CREATE TABLE Reservation(
    rid VARCHAR(20) NOT NULL,
    dateReservation DATETIME NOT NULL,
    dateConfirmation DATETIME ,
    email VARCHAR(32) NOT NULL,
    PRIMARY KEY (rid),
    FOREIGN KEY (email) REFERENCES User_(uemail) ON DELETE NO ACTION,
    CHECK (dateReservation < dateConfirmation),
    CHECK (DATEDIFF(dateConfirmation, dateReservation) <= 1)
);

CREATE TABLE Flight(
    fid VARCHAR(20) NOT NULL,
    arrivalTime DATETIME NOT NULL,
    departureTime DATETIME NOT NULL,
    destination VARCHAR(20) NOT NULL,
    departure VARCHAR(20) NOT NULL,
    registrationNumber INT NOT NULL,
    PRIMARY KEY (fid),
    FOREIGN KEY (registrationNumber) REFERENCES Airplane(registrationNumber) ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE FidelityCard(
    fctype VARCHAR(20) ,
    reduction INT  CHECK (reduction BETWEEN 0 AND 70),
    PRIMARY KEY (fctype)
);

CREATE TABLE PassengerCard(
    fcid VARCHAR(64),
    fctype VARCHAR(20),
    PRIMARY KEY (fcid),
    FOREIGN KEY (fctype) REFERENCES FidelityCard(fctype) ON DELETE CASCADE
);

CREATE TABLE Passenger(
    passportID VARCHAR(20),
    cin VARCHAR(20),
    pbirthDate DATE NOT NULL,
    phoneNumber VARCHAR(20),
    pfirstName VARCHAR(32) NOT NULL,
    plastName VARCHAR(32) NOT NULL,
    fcid VARCHAR(64),
    PRIMARY KEY (passportID),
    FOREIGN KEY (fcid) REFERENCES PassengerCard(fcid) ON DELETE SET NULL
);

CREATE TABLE Ticket(
    tid VARCHAR(20) NOT NULL,
    seatNumber INT,
    price FLOAT NOT NULL,
    passportID VARCHAR(20) NOT NULL,
    rid VARCHAR(20) NOT NULL,
    fid VARCHAR(20) NOT NULL,
    fctype VARCHAR(20) ,
    class VARCHAR(20) NOT NULL,
    PRIMARY KEY (tid),
    FOREIGN KEY (fctype) REFERENCES FidelityCard(fctype) ON DELETE SET NULL,
    FOREIGN KEY (passportID) REFERENCES Passenger(passportID) ON DELETE CASCADE,
    FOREIGN KEY (rid) REFERENCES Reservation(rid)ON DELETE CASCADE,
    FOREIGN KEY (fid) REFERENCES Flight(fid) ON DELETE NO ACTION
);

CREATE TABLE Checks(
    email VARCHAR(32) NOT NULL,
    fid VARCHAR(20) NOT NULL,
    PRIMARY KEY (email, fid),
    FOREIGN KEY (email) REFERENCES User_(uemail) ON DELETE CASCADE,
    FOREIGN KEY (fid) REFERENCES Flight(fid) ON DELETE CASCADE
);

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

DELIMITER //
CREATE TRIGGER checkValidReservation
AFTER UPDATE ON Reservation
FOR EACH ROW
BEGIN
    DECLARE adult_count INT;

    SELECT COUNT(*) INTO adult_count
    FROM Ticket
    INNER JOIN Passenger ON Ticket.passportID = Passenger.passportID
    WHERE Ticket.rid = OLD.rid AND YEAR(CURDATE()) - YEAR(Passenger.pbirthDate) >= 16;
	    
    IF adult_count = 0 AND OLD.dateConfirmation IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reservation refused. No accompanying adult is registered.';
    END IF;
END;
//

//
CREATE TRIGGER user_age_check
BEFORE INSERT ON User_
FOR EACH ROW
BEGIN
    IF DATEDIFF(NOW(), NEW.ubirthDate) < 6570 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Users must be 18 years or older.';
    END IF;
END;
//



    
