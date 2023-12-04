DROP DATABASE IF EXISTS Project2;
CREATE DATABASE Project2;
USE Project2;


CREATE TABLE FidelityCard(
    fctype VARCHAR(20) ,
    reduction INT  CHECK (reduction BETWEEN 0 AND 100),
    PRIMARY KEY (fctype)
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
    airline VARCHAR(20) NOT NULL,
    model VARCHAR(20) NOT NULL,
    PRIMARY KEY (registrationNumber),
    FOREIGN KEY (model) REFERENCES AirplaneModel(model) ON DELETE no action
    ON UPDATE CASCADE
);

CREATE TABLE User_ (
    uemail VARCHAR(20) NOT NULL,
    ufirstName VARCHAR(20) NOT NULL,
    ulastName VARCHAR(20) NOT NULL,
    ubirthDate DATE NOT NULL ,
    passwordHash VARCHAR(64) NOT NULL,
    PRIMARY KEY (uemail)
);

CREATE TABLE Reservation (
    rid VARCHAR(20) NOT NULL,
    dateReservation DATETIME NOT NULL,
    dateConfirmation DATETIME ,
    email VARCHAR(20) NOT NULL,
    PRIMARY KEY (rid),
    FOREIGN KEY (email) REFERENCES User_(uemail) ON DELETE no action,
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

CREATE TABLE Checks(
    email VARCHAR(20) NOT NULL,
    fid VARCHAR(20) NOT NULL,
    PRIMARY KEY (email, fid),
    FOREIGN KEY (email) REFERENCES User_(uemail) ON DELETE cascade ,
    
    FOREIGN KEY (fid) REFERENCES Flight(fid) on delete cascade
);

CREATE TABLE Passenger(
    passportID VARCHAR(20),
    cin VARCHAR(20),
    pbirthDate DATE NOT NULL,
    phoneNumber VARCHAR(20),
    pfirstName VARCHAR(20) NOT NULL,
    plastName VARCHAR(20) NOT NULL,
    fcid VARCHAR(20),
    PRIMARY KEY (passportID),
    FOREIGN KEY (fcid) REFERENCES PassengerCard(fcid) on delete set null
);

CREATE TABLE PassengerCard(
    fcid VARCHAR(20),
    fctype VARCHAR(20),
    PRIMARY KEY (fcid),
    FOREIGN KEY (fctype) REFERENCES FidelityCard(fctype) on delete cascade
);

CREATE TABLE Ticket(
    tid VARCHAR(20) NOT NULL,
    seatNumber INT UNIQUE,
    price FLOAT NOT NULL,
    passportID VARCHAR(20) NOT NULL,
    rid VARCHAR(20) NOT NULL,
    fid VARCHAR(20) NOT NULL,
    fctype VARCHAR(20) ,
    class VARCHAR(20) NOT NULL,
    PRIMARY KEY (tid),
    FOREIGN KEY (fctype) REFERENCES FidelityCard(fctype) on delete set null,
    FOREIGN KEY (passportID) REFERENCES PassengerInfos(passportID) on delete cascade,
    FOREIGN KEY (rid) REFERENCES Reservation(rid)on delete cascade,
    FOREIGN KEY (fid) REFERENCES Flight(fid) on delete no action
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
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
    DECLARE adult_count INT;

    -- number of accompanying adults 
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

//
CREATE TRIGGER reservation_dates_check
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
    IF DATEDIFF(NOW(), NEW.dateConfirmation) <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'dates of reservation are not valid';
    END IF;
END;
//

CREATE ROLE 'user', 'airline', 'admin';

GRANT ALL ON project2.Flight  TO 'airline';
GRANT ALL ON project2.Airplane  TO 'airline';
GRANT SELECT ON project2.Checks TO 'admin';
GRANT ALL ON project2.Reservation TO 'admin';
GRANT SELECT ON project2.Flight TO 'user';

DELIMITER //
CREATE PROCEDURE CreateReservationView(IN user_email VARCHAR(32))
BEGIN
    DECLARE view_name VARCHAR(46);
    DECLARE sql_query VARCHAR(164);
    DECLARE grant_query VARCHAR(86);

    SET @view_name = CONCAT(SUBSTRING_INDEX(user_email, '@', 1), 'ReservationView');
    SET @sql_query = CONCAT('CREATE VIEW ', @view_name, ' AS
        SELECT rid, rdate, confirmDate
        FROM Reservation
        JOIN User
        ON Reservation.uemail = User.uemail
        WHERE User.uemail = ', QUOTE(user_email));

    PREPARE stmt FROM @sql_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @grant_query = CONCAT('GRANT INSERT, UPDATE, DELETE ON project2.', @view_name, ' TO `user`');
    PREPARE stmt FROM @grant_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
 
DELIMITER //
CREATE PROCEDURE CreatePassengerView(IN user_email VARCHAR(32))
BEGIN
		DECLARE view_name VARCHAR(46);
        DECLARE sql_query VARCHAR(164);
        DECLARE grant_query VARCHAR(86);
	SET @view_name = CONCAT(SUBSTRING_INDEX(user_email, @, 1), 'PassengerView');
	SET @sql_query = CONCAT('CREATE VIEW', @view_name, 'AS 
	CREATE VIEW PassengerView AS
	SELECT passportID, cin, pfirstName AS firstName, plastName AS lastName, phoneNumber, pbirthDate AS birthDate
	FROM Passenger
	JOIN Ticket ON Ticket.passportID = Passenger.passportID
	JOIN Reservation ON Reservation.rid = Ticket.rid
	JOIN User ON User.uemail = Reservation.uemail
	WHERE User.uemail = ', QUOTE(user_email), ';');
	PREPARE stmt FROM @sql_query;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	SET @grant_query = CONCAT('GRANT INSERT, UPDATE, DELETE ON project2.', @view_name, ' TO `user`');
   	PREPARE stmt FROM @grant_query;
   	EXECUTE stmt;
    	DEALLOCATE PREPARE stmt;
END //
