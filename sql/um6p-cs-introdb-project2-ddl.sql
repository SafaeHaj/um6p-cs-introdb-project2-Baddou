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
    FOREIGN KEY (model) REFERENCES AirplaneModel(model) ON DELETE no action
    ON UPDATE CASCADE
);

CREATE TABLE Reservation (
    rid VARCHAR(20) NOT NULL,
    dateReservation DATETIME NOT NULL,
    dateConfirmation DATETIME ,
    email VARCHAR(32) NOT NULL,
    PRIMARY KEY (rid),
    FOREIGN KEY (email) REFERENCES User_(uemail) ON DELETE no action,
    CHECK (dateReservation <= dateConfirmation),
    CHECK (DATEDIFF(dateConfirmation, dateReservation) <= 1)
);

CREATE TABLE Flight(
    fid VARCHAR(20) NOT NULL,
    arrivalTime DATETIME NOT NULL,
    departureTime DATETIME NOT NULL,
    destination VARCHAR(64) NOT NULL,
    departure VARCHAR(64) NOT NULL,
    registrationNumber INT NOT NULL,
    price FLOAT NOT NULL,
    status_ VARCHAR(20) default 'Available',
    PRIMARY KEY (fid),
    FOREIGN KEY (registrationNumber) REFERENCES Airplane(registrationNumber) ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE FidelityCard(
    fctype VARCHAR(20) ,
    reduction INT  CHECK (reduction BETWEEN 0 AND 100),
    PRIMARY KEY (fctype)
);

CREATE TABLE PassengerCard(
    fcid VARCHAR(64),
    fctype VARCHAR(20),
    PRIMARY KEY (fcid),
    FOREIGN KEY (fctype) REFERENCES FidelityCard(fctype) on delete cascade
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
    FOREIGN KEY (fcid) REFERENCES PassengerCard(fcid) on delete set null
);

CREATE TABLE Ticket(
    tid VARCHAR(20) NOT NULL,
    seatNumber INT NOT NULL,
    passportID VARCHAR(20) NOT NULL,
    rid VARCHAR(20) NOT NULL,
    fid VARCHAR(20) NOT NULL,
    fctype VARCHAR(20) ,
    class VARCHAR(20) NOT NULL,
    PRIMARY KEY (tid),
    FOREIGN KEY (fctype) REFERENCES FidelityCard(fctype) on delete set null,
    FOREIGN KEY (passportID) REFERENCES Passenger(passportID) on delete cascade,
    FOREIGN KEY (rid) REFERENCES Reservation(rid)on delete cascade,
    FOREIGN KEY (fid) REFERENCES Flight(fid) on delete no action
);

CREATE TABLE Checks(
    email VARCHAR(32) NOT NULL,
    fid VARCHAR(20) NOT NULL,
    PRIMARY KEY (email, fid),
    FOREIGN KEY (email) REFERENCES User_(uemail) ON DELETE cascade ,
    
    FOREIGN KEY (fid) REFERENCES Flight(fid) on delete cascade
);

CREATE INDEX idx_Flight_at ON Flight (arrivalTime);
CREATE INDEX idx_Flight_dp ON Flight (departureTime);
CREATE INDEX idx_Flight_dest ON Flight (destination);
-- a reservation cannot be valid if it contains only minors or is empty
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

-- check the age of users (NOW() and such functions can't be used within create table statements
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


