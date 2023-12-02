CREATE DATABASE Project2

CREATE TABLE Reservation{
    rid VARCHAR(20) NOT NULL,
    dateReservation DATETIME NOT NULL,
    dateConfirmation DATETIME NOT NULL,
    email VARCHAR(20) NOT NULL,
    PRIMARY KEY (rid),
    FOREIGN KEY (email) REFERENCES User(email)
};

CREATE TABLE User{
    email VARCHAR(20) NOT NULL,
    ufirstName VARCHAR(20) NOT NULL,
    ulastName VARCHAR(20) NOT NULL,
    ubirthDate DATE NOT NULL Check(DATEDIFF(NOW() - ubirthDate) >= 18),
    passwordHash VARCHAR(20) NOT NULL,
    PRIMARY KEY (email)
};

CREATE TABLE Checks{
    email VARCHAR(20) NOT NULL,
    flightID VARCHAR(20) NOT NULL,
    PRIMARY KEY (email, flightID),
    FOREIGN KEY (email) REFERENCES User(email),
    FOREIGN KEY (flightID) REFERENCES Flight(flightID)
};


CREATE TABLE Ticket{
    ticketID VARCHAR(20) NOT NULL,
    seatNumber INT NOT NULL,
    price FLOAT NOT NULL,
    cin VARCHAR(20) NOT NULL,
    rid VARCHAR(20) NOT NULL,
    flightID VARCHAR(20) NOT NULL,
    PRIMARY KEY (ticketID),
    FOREIGN KEY (cin) REFERENCES PassengerInfos(cin),
    FOREIGN KEY (rid) REFERENCES Reservation(rid),
    FOREIGN KEY (flightID) REFERENCES Flight(flightID)
};

CREATE TABLE ClassInfo{
    flightID VARCHAR(20) NOT NULL,
    seatNumber INT NOT NULL,    
    class VARCHAR(20) NOT NULL,
    PRIMARY KEY (flightID, seatNumber),
    FOREIGN KEY (flightID) REFERENCES Flight(flightID),
    FOREIGN KEY (seatNumber) REFERENCES Ticket(seatNumber)
};

CREATE TABLE PassengerInfos{
    cin VARCHAR(20) NOT NULL,
    pbirthDate DATE NOT NULL,
    passportID VARCHAR(20) NOT NULL,
    phoneNumber VARCHAR(20),
    pfirstName VARCHAR(20) NOT NULL,
    plastName VARCHAR(20) NOT NULL,
    fid VARCHAR(20),
    PRIMARY KEY (cin),
    FOREIGN KEY (fid) REFERENCES PassengerCard(fid)
};

CREATE TABLE PassengerCard{
    fctype VARCHAR(20) NOT NULL,
    fid VARCHAR(20) NOT NULL,
    PRIMARY KEY (fid),
    FOREIGN KEY (fctype) REFERENCES FidelityCard(fctype)
};

CREATE TABLE FidelityCard{
    fctype VARCHAR(20) NOT NULL,
    reduction INT NOT NULL,
    PRIMARY KEY (fctype)
};


CREATE TABLE Apply{
    fctype VARCHAR(20) NOT NULL,
    ticketID VARCHAR(20) NOT NULL,
    FOREIGN KEY (fctype) REFERENCES FidelityCard(fctype),
    FOREIGN KEY (ticketID) REFERENCES Ticket(ticketID)
};

CREATE TABLE AirplaneModel{
    seats INT,
    maxweight INT,
    model VARCHAR(20),
    PRIMARY KEY (model),
};

CREATE TABLE AirplaneInfos{
    registrationNumber INT NOT NULL,
    airline VARCHAR(20) NOT NULL,
    model VARCHAR(20) NOT NULL,
    PRIMARY KEY (registrationNumber),
};

CREATE TABLE Flight{
    flightID VARCHAR(20) NOT NULL,
    arrivalTime DATETIME NOT NULL,
    departureTime DATETIME NOT NULL,
    destination VARCHAR(20) NOT NULL,
    departure VARCHAR(20) NOT NULL,
    registrationNumber INT NOT NULL,
    PRIMARY KEY (flightID),
    FOREIGN KEY (registrationNumber) REFERENCES AirplaneInfos
};