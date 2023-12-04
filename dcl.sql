GRANT SELECT ON project2.Checks TO 'admin';
GRANT ALL ON project2.Reservation TO 'admin';
GRANT SELECT ON project2.Flight TO 'user';

DELIMITER //
CREATE PROCEDURE on_user_add(IN user_email VARCHAR(32))
BEGIN
    DECLARE user_name VARCHAR(32);
    SET user_name = SUBSTRING_INDEX(user_email, '@', 1);
    CREATE USER user_name;
    GRANT 'user' TO user_name;
END;
//

DELIMITER //
CREATE TRIGGER trig_on_user_add AFTER INSERT ON User_
FOR EACH ROW
BEGIN 
    CALL on_user_add(NEW.uemail);
END;
//

DELIMITER //
CREATE PROCEDURE on_user_delete(IN user_email VARCHAR(32))
BEGIN
	DECLARE user_name VARCHAR(32);
    IF EXISTS (SELECT 1 FROM project2.User_ WHERE user = user_name) THEN
		SET user_name = SUBSTRING_INDEX(user_email, '@', 1);
		REVOKE 'user' FROM user_name;
		DROP USER user_name;
    END IF;
END;//

DELIMITER //
CREATE TRIGGER trig_on_user_delete BEFORE DELETE ON User_
FOR EACH ROW 
BEGIN
    CALL on_user_delete(OLD.uemail);
END;//

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
		SELECT passportID, cin, pfirstName AS firstName, plastName AS lastName, phoneNumber, pbirthDate AS birthDate
		FROM Passenger JOIN Ticket ON Ticket.passportID = Passenger.passportID
		JOIN Reservation ON Reservation.rid = Ticket.rid
		JOIN User ON User.uemail = Reservation.uemail
		WHERE User.uemail = ', user_email, ';
		GRANT SELECT, INSERT, UPDATE, DELETE ON project2.', @view_name, ' TO', user_name,';');

   	PREPARE stmt FROM @create_user_view;
   	EXECUTE stmt;
    	DEALLOCATE PREPARE stmt;
END; 
// 

DELIMITER //
CREATE FUNCTION acronymize(name VARCHAR(64)) RETURNS VARCHAR(32) DETERMINISTIC
BEGIN
    DECLARE acronomized VARCHAR(32) DEFAULT '';
    DECLARE i INT DEFAULT 1;

    SET name = TRIM(name);

    WHILE i <= LENGTH(name) - LENGTH(REPLACE(name, ' ', '')) + 1 DO
        SET acronomized = CONCAT(acronomized, UPPER(SUBSTRING_INDEX(SUBSTRING_INDEX(name, ' ', i), ' ', -1)));
        SET i = i + 1;
    END WHILE;

    RETURN acronomized;
END;//
	
DELIMITER //

CREATE PROCEDURE CreateAirline(IN airline VARCHAR(64)) -- to call in loop in order to generate airline accounts
BEGIN
   DECLARE airline_acronym VARCHAR(32);
   SET airline_acronym = acronomize(airline);
   
   IF NOT EXISTS (SELECT 1 FROM mysql.user WHERE user = airline_acronym) THEN
        CREATE USER airline_acronym;
        GRANT 'airline' TO airline_acronym;
   END IF;
END; 

//

DELIMITER ;

DELIMITER //
CREATE PROCEDURE CreateAirplaneView(IN airline VARCHAR(64))
BEGIN
	DECLARE airline_acronym VARCHAR(32);
	SET airline_acronym = acronomize(airline);
	IF NOT EXISTS (SELECT 1 FROM mysql.user WHERE user = airline_acronym) THEN
	    SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The airline you entered does not exist';
	END IF;
	
	SET @view_name = CONCAT(airline_acronym, 'AirplaneView');
	SET @create_view = CONCAT('CREATE VIEW', @view_name, 'AS 
		SELECT *
		FROM Airplane
		WHERE Airplane.airline = ', airline, ';
		GRANT SELECT, INSERT, DELETE ON project2.', @view_name, ' TO', airline_acronym,';');

   	PREPARE stmt FROM @create_view;
   	EXECUTE stmt;
    	DEALLOCATE PREPARE stmt;
END; 
//

DELIMITER //
CREATE PROCEDURE CreateAirplaneModelView(IN airline VARCHAR(64))
BEGIN
	DECLARE airline_acronym VARCHAR(32);
	SET airline_acronym = acronomize(airline);
	IF NOT EXISTS (SELECT 1 FROM mysql.user WHERE user = airline_acronym) THEN
	    SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The airline you entered does not exist';
	END IF;
	
	SET @view_name = CONCAT(airline_acronym, 'AirplaneModelView');
	SET @create_view = CONCAT('CREATE VIEW', @view_name, 'AS 
		SELECT *
		FROM AirplaneModel
		JOIN Airplane ON Airplane.model = AirplaneModel.model
		WHERE AirplaneModel.airline = ', airline, ';
		GRANT SELECT, INSERT, DELETE ON project2.', @view_name, ' TO', airline_acronym,';');

   	PREPARE stmt FROM @create_view;
   	EXECUTE stmt;
    	DEALLOCATE PREPARE stmt;
END; 
//
END; 
//


