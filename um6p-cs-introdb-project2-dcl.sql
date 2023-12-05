CREATE ROLE 'user', 'airline', 'admin';

GRANT SELECT ON project2.Checks TO 'admin';
GRANT ALL ON project2.Reservation TO 'admin';
GRANT SELECT ON project2.Flight TO 'user';

-----------------------------------------------------
-----User account creation on Project2.User_ add-----
-----------------------------------------------------
DELIMITER //
CREATE PROCEDURE on_user_add(IN user_email VARCHAR(32), IN password_user VARCHAR(64))
BEGIN
    SET @create_user_query = CONCAT('CREATE USER ', QUOTE(user_email), '@\'%\' IDENTIFIED BY ', QUOTE(password_user), ';
	GRANT ''user'' TO ', QUOTE(user_email));
    PREPARE create_user_stmt FROM @create_user_query;
    EXECUTE create_user_stmt;
    DEALLOCATE PREPARE create_user_stmt;
END;
//
-----------------------------------------------------
-----User account deletion on Project2.User_ delete--
-----------------------------------------------------
DELIMITER //
CREATE PROCEDURE on_user_delete(IN user_email VARCHAR(32))
BEGIN
    SET @revok_delete_query = CONCAT('REVOKE ''user'' FROM ', QUOTE(user_email), ';DROP USER ', QUOTE(user_email));
    PREPARE revoke_stmt FROM @revoke_delete_query;
    EXECUTE revoke_stmt;
    DEALLOCATE PREPARE revoke_stmt;
END;
//
-----------------------------------------------------
-----Grant row access on user's reservation----------
-----------------------------------------------------
DELIMITER //
CREATE PROCEDURE create_reservation_view(IN user_email VARCHAR(32))
BEGIN
    SET @view_name = CONCAT(user_email, 'ReservationView');
    SET @create_user_view = CONCAT('CREATE VIEW ', @view_name, ' AS
        SELECT rid,
        FROM Reservation JOIN User
        ON Reservation.uemail = User.uemail
        WHERE User.uemail = ', user_email,
	"GRANT SELECT, INSERT, UPDATE, DELETE ON project2.", @view_name, " TO ",user_email, ';');

    PREPARE stmt FROM @create_user_view;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

---------------------------------------------------------------
-----Grant row access on user's registered passengers----------
---------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE create_passenger_view(IN user_email VARCHAR(32))
BEGIN
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

--------------------------------------
-----Airline user account handling----
--------------------------------------
/* 
   Our database's airline names are too long to be put directly
   as user names, thus the need to acronomize them via this function
*/
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

--------------------------------------
-----Airline user account creation----
--------------------------------------
DELIMITER //
CREATE PROCEDURE create_airline(IN airline VARCHAR(64), IN airline_password VARCHAR(64))
BEGIN
   DECLARE acronym_airline VARCHAR(32);
   SET acronym_airline = acronymize(airline);
   SET @create_airline_query = CONCAT('CREATE USER ', QUOTE(acronym_airline), '@\'%\' IDENTIFIED BY ', QUOTE(airline_password), ';
	GRANT ''airline'' TO ', QUOTE(acronym_airline));

   PREPARE create_airline_stmt FROM @create_airline_query;
   EXECUTE create_airline_stmt;
   DEALLOCATE PREPARE create_airline_stmt;
END; 
//

------------------------------------------------
-----Grant row access to airline's airplanes----
------------------------------------------------
DELIMITER //
CREATE PROCEDURE CreateAirplaneView(IN airline VARCHAR(64))
BEGIN
	DECLARE airline_acronym VARCHAR(32);
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

------------------------------------------------------
-----Grant row access to airline's airplane models----
------------------------------------------------------
DELIMITER //
CREATE PROCEDURE CreateAirplaneModelView(IN airline VARCHAR(64))
BEGIN	
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

