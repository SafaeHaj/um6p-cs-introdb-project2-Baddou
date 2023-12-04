CREATE ROLE 'user', 'airline', 'admin';

GRANT ALL ON project2.Flight  TO 'airline';
GRANT ALL ON project2.Airplane  TO 'airline';
GRANT SELECT ON project2.Checks TO 'admin';
GRANT ALL ON project2.Reservation TO 'admin';
GRANT SELECT ON project2.Flight TO 'user';
/*

Problem with determining specifically airline users out of mysql.user table- TO DISCUSS

DELIMITER //
CREATE TRIGGER on_airline_delete BEFORE DELETE ON mysql.user
FOR EACH ROW
BEGIN
    IF 
	DELETE FROM Airplane
	WHERE Airplane.airline = OLD;
	REVOKE 'airline' FROM OLD;
	DROP OLD;
    END IF;
END;
//
*/

DELIMITER //
CREATE TRIGGER on_user_add AFTER INSERT ON User
FOR EACH ROW
BEGIN
    DECLARE user_name VARCHAR(32);
    DECLARE create_user VARCHAR(186);

    SET user_name = SUBSTRING_INDEX(NEW.uemail, '@', 1);

    IF NOT EXISTS (SELECT 1 FROM mysql.user WHERE user = user_name) THEN
        SET create_user = CONCAT("CREATE USER ", user_name, "; GRANT 'user' TO ", user_name, ';');
        PREPARE stmt FROM @create_user;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END;
//

DELIMITER//
CREATE TRIGGER on_user_delete BEFORE DELETE ON User
FOR EACH ROW
BEGIN
    DECLARE user_name VARCHAR(32);
    DECLARE delete_user VARCHAR(200);
    
    SET user_name = SUBSTRING_INDEX(OLD.uemail, '@', 1);

    IF EXISTS (SELECT 1 FROM mysql.user WHERE user = user_name) THEN
        SET delete_user = CONCAT("REVOKE 'user' FROM ", user_name, ";DROP ", user_name, ';');
	PREPARE stmt FROM @delete_user;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CreateReservationView(IN user_email VARCHAR(32))
BEGIN
    DECLARE user_name VARCHAR(32);
    SET user_name = SUBSTRING_INDEX(user_email, '@', 1);
    IF NOT EXISTS (SELECT 1 FROM mysql.user WHERE user = user_name) THEN
	SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The user you entered does not exist';
    END IF;

    SET @view_name = CONCAT(SUBSTRING_INDEX(user_email, '@', 1), 'ReservationView');
    SET @create_user_view = CONCAT('CREATE VIEW ', @view_name, ' AS
        SELECT rid, rdate, confirmDate
        FROM Reservation JOIN User
        ON Reservation.uemail = User.uemail
        WHERE User.uemail = ', user_email,
	"GRANT SELECT, INSERT, UPDATE, DELETE ON project2.", @view_name, " TO ", user_name, ';');

    PREPARE stmt FROM @create_user_view;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE CreatePassengerView(IN user_email VARCHAR(32))
BEGIN
	DECLARE user_name VARCHAR(32);
	SET user_name = SUBSTRING_INDEX(user_email, '@', 1);
	IF NOT EXISTS (SELECT 1 FROM mysql.user WHERE user = user_name) THEN
	    SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The user you entered does not exist';
	END IF;

	SET @view_name = CONCAT(SUBSTRING_INDEX(user_email, '@', 1), 'PassengerView');
	SET @create_user_view = CONCAT('CREATE VIEW', @view_name, 'AS 
		CREATE VIEW PassengerView AS
		SELECT passportID, cin, pfirstName AS firstName, plastName AS lastName, phoneNumber, pbirthDate AS birthDate
		FROM Passenger JOIN Ticket ON Ticket.passportID = Passenger.passportID
		JOIN Reservation ON Reservation.rid = Ticket.rid
		JOIN User ON User.uemail = Reservation.uemail
		WHERE User.uemail = ', user_email, ';
		GRANT SELECT, INSERT, UPDATE, DELETE ON project2.', @view_name, ' TO', user_name,';');

   	PREPARE stmt FROM @create_user_view;
   	EXECUTE stmt;
    	DEALLOCATE PREPARE stmt;
END //
DELIMITER;
