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
    
    SELECT COUNT(*) INTO reservationExists
    FROM Reservation
    WHERE rid = rid1;
    
    SELECT MAX(seatNumber) +1 INTO seatnumber
    FROM Ticket
    WHERE fid=fid and class=ticketClass;
    
    SELECT COUNT(*) INTO tidExists
    FROM Ticket
    WHERE tid = ticketId;
    START TRANSACTION;
    
    IF reservationExists > 0 AND tidExists=0 THEN 
		INSERT INTO Ticket (tid, seatNumber, passportID, rid, fid, fctype, class) VALUES (ticketId, seatnumber, passportId, rid1, fid, fctype, ticketClass);  
	else
		ROLLBACK;
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = ' Ticket already exists in a reservation';
	END IF;
    
    COMMIT;
    
END //




USE project2;
drop procedure if exists CalculateTicketPrice;
DELIMITER //


CREATE PROCEDURE CalculateTicketPrice(
	IN TicketClass VARCHAR(20),
    IN FidelityCardType VARCHAR(20) , 
	in Fid VARCHAR(20)
) 

BEGIN 
	DECLARE BasePrice FLOAT;
    DECLARE FidelityDiscount FLOAT;
    DECLARE TicketPrice FLOAT;
    SET BasePrice =( SELECT F.price 
								FROM Flight F 
                                WHERE F.fid = Fid
                                LIMIT 1);

    IF FidelityCardType is  NOT NULL THEN 
		SET FidelityDiscount = COALESCE((SELECT reduction FROM FidelityCard WHERE fctype = FidelityCardType), 0) / 100;
        ELSE
			SET FidelityDiscount = 0;
		END IF;
                
        IF TicketClass = 'J' THEN 
			SET TicketPrice = BasePrice -(BasePrice * (FidelityDiscount + 0.1));
            
		ELSEIF TicketClass = 'FC' THEN 
			SET TicketPrice = BasePrice - (BasePrice * (FidelityDiscount + 0.2));
		
        ELSEIF TicketClass = 'Y+' THEN
			SET TicketPrice = BasePrice - (BasePrice * (FidelityDiscount + 0.05));
		ELSE 
			SET TicketPrice = BasePrice - (BasePrice * FidelityDiscount);
		END IF;
       
        SELECT BasePrice, TicketPrice, FidelityDiscount ;
	END; // 
) 
