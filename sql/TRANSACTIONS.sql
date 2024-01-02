USE project2;

DROP PROCEDURE IF EXISTS CancelFlight;

DROP PROCEDURE IF EXISTS BookFlightWithFidelityCard;
DROP PROCEDURE IF EXISTS AddTicketToReservation;



-- Create a stored procedure for flight cancellation (Working)
DELIMITER //

CREATE PROCEDURE CancelFlight(IN pFid VARCHAR(20))
BEGIN
	START TRANSACTION;
    Update Flight SET status_ = 'Cancelled' Where fid = pFid;
    DELETE FROM Ticket WHERE fid = pFID;

    
    COMMIT;
END //

DELIMITER ;

-- Create Procedure to add ticket to reservation
DELIMITER //

CREATE PROCEDURE AddTicketToReservation(
	IN ticketId VARCHAR(20),
    IN seatNumber INT,
    IN passportID VARCHAR(20),
    IN rid1 VARCHAR(20),
    IN fid VARCHAR(20),
    IN fctype VARCHAR(20),
    IN ticketClass VARCHAR(20)
)

BEGIN 

	DECLARE reservationExists INT;
    DECLARE tidExists INT;
    
    SELECT COUNT(*) INTO reservationExists
    FROM Reservation
    WHERE rid = rid1;
    
    SELECT COUNT(*) INTO tidExists
    FROM Ticket
    WHERE tid = ticketId;
    select tidExists;
    START TRANSACTION;
    
    IF reservationExists = 0 AND tidExists=0 THEN 
		INSERT INTO Ticket (tid, seatNumber, passportID, rid, fid, fctype, class) VALUES (ticketId, seatNumber, passportId, rid1, fid, fctype, ticketClass);  
	else
		ROLLBACK;
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Reservation id already exist';
	END IF;
    
    COMMIT;
    
END //

DELIMITER ;

