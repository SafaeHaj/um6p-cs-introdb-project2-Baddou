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
