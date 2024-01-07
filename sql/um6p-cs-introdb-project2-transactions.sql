USE project2;

DROP PROCEDURE IF EXISTS CancelFlight;
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
    IN passportID VARCHAR(20),
    IN rid1 VARCHAR(20),
    IN fid VARCHAR(20),
    IN fctype VARCHAR(20),
    IN ticketClass VARCHAR(20)
)

BEGIN 

    DECLARE reservationExists INT;
    DECLARE tidExists INT;
    DECLARE seatnumber INT;
    
    SELECT COUNT(*) INTO reservationExists
    FROM Reservation
    WHERE rid = rid1;
    
    SELECT COALESCE(MAX(seatNumber) + 1, 1) INTO seatnumber
    FROM Ticket
    WHERE fid=fid and class=ticketClass;
    
    SELECT COUNT(*) INTO tidExists
    FROM Ticket
    WHERE tid = ticketId;
    START TRANSACTION;
    
    IF tidExists=0 THEN 
		INSERT INTO Ticket (tid, seatNumber, passportID, rid, fid, fctype, class) VALUES (ticketId, seatnumber, passportId, rid1, fid, fctype, ticketClass);  
	else
		ROLLBACK;
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = ' Ticket already exists in a reservation';
	END IF;
    
    COMMIT;
    
END //

DELIMITER ;



