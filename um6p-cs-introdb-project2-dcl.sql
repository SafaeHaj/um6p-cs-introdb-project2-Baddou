CREATE ROLE 'user', 'airline', 'admin';

GRANT SELECT ON project2.Checks TO 'admin';
GRANT ALL ON project2.Reservation TO 'admin';
GRANT SELECT ON project2.Flight TO 'user';


/*
------------------------------------
-----User account handling----------
------------------------------------
*/
DELIMITER //
CREATE PROCEDURE grant_user_views(IN user_email VARCHAR(32))
BEGIN
    SET @reservation_view = CONCAT(user_email, 'ReservationView');
    SET @passenger_view = CONCAT(user_email, 'PassengerView');

    SET @create_user_view = CONCAT('CREATE VIEW ', @reservation_view, ' AS
        SELECT *,
        FROM Reservation R JOIN User_ U
        ON R.uemail = U.uemail
        WHERE U.uemail = ', QUOTE(user_email),';',
	'CREATE VIEW', @passenger_view, 'AS 
	SELECT passportID, cin, pfirstName AS firstName, plastName AS lastName, phoneNumber, pbirthDate AS birthDate
	FROM Passenger P JOIN Ticket T ON T.passportID = P.passportID
	JOIN Reservation R ON R.rid = T.rid
	JOIN User_ U ON U.uemail = R.email
	WHERE U.uemail = ', QUOTE(user_email), ';');

    SET @grant_user = CONCAT('GRANT SELECT, INSERT, UPDATE, DELETE ON project2.', @reservation_view, " TO ",user_email, ';',
	    		    'GRANT SELECT, INSERT, UPDATE, DELETE ON project2.', @passenger_view, " TO ",user_email, ';');

    PREPARE create_stmt FROM @create_user_view;
    EXECUTE create_stmt;
    DEALLOCATE PREPARE create_stmt;

    PREPARE grant_stmt FROM @grant_user;
    EXECUTE grant_stmt;
    DEALLOCATE PREPARE grant_stmt;
END // 
/*
-------------------------------
-----User account creation-----
-------------------------------
*/
DELIMITER //
CREATE PROCEDURE on_user_add(IN user_email VARCHAR(32), IN password_user VARCHAR(64))
BEGIN
    DECLARE user_name VARCHAR(32);
    SET user_name = REPLACE( REPLACE(user_email, '@',''), '.', '');
    SET @create_user_query = CONCAT('CREATE USER ', QUOTE(user_name), '@\'%\' IDENTIFIED BY ', QUOTE(password_user), ';');
    SET @grant_user = CONCAT('GRANT ''user'' TO ', QUOTE(user_name));
    
    PREPARE create_user_stmt FROM @create_user_query;
    EXECUTE create_user_stmt;
    DEALLOCATE PREPARE create_user_stmt;

    PREPARE create_user_stmt FROM @grant_user;
    EXECUTE create_user_stmt;
    DEALLOCATE PREPARE create_user_stmt;

    CALL grant_user_views(user_email);
END;
//

/*
-------------------------------
-----User account deletion-----
-------------------------------
*/
DELIMITER //
CREATE PROCEDURE on_user_delete(IN user_email VARCHAR(32))
BEGIN
    DECLARE user_name VARCHAR(32);
    SET user_name = REPLACE( REPLACE(user_email, '@',''), '.', '');
    SET @revoke_query = CONCAT('REVOKE ''user'' FROM ', QUOTE(user_name), ';');
    SET @drop_query = CONCAT('DROP USER ', QUOTE(user_name));

    PREPARE revoke_stmt FROM @revoke_query;
    EXECUTE revoke_stmt;
    DEALLOCATE PREPARE revoke_stmt;

    PREPARE drop_stmt FROM @drop_query;
    EXECUTE drop_stmt;
    DEALLOCATE PREPARE revoke_stmt;
END;
//
	
/* 
--------------------------------------
-----Airline user account handling----
--------------------------------------
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

/*
------------------------------------------------
-----Grant row view access to airline-----------
------------------------------------------------
*/
DELIMITER //
CREATE PROCEDURE create_airline_views(IN airline VARCHAR(64))
BEGIN
    DECLARE airline_acronym VARCHAR(32);
    SET airline_acronym = acronymize(airline);

    SET @airplane_view_name = CONCAT(airline_acronym, 'AirplaneView');
    SET @airplane_model_view_name = CONCAT(airline_acronym, 'AirplaneModelView');


    SET @create_airline_view = CONCAT('CREATE VIEW ', @airplane_view_name, ' AS
        SELECT *
        FROM Airplane
        WHERE Airplane.airline = ', QUOTE(airline), ';',
        'CREATE VIEW ', @airplane_model_view_name, ' AS
        SELECT *
        FROM AirplaneModel
        JOIN Airplane ON Airplane.model = AirplaneModel.model
        WHERE AirplaneModel.airline = ', QUOTE(airline), ';'
        );

    SET @grant_airline = CONCAT(
        'GRANT SELECT, INSERT, DELETE ON project2.', @airplane_view_name, ' TO ', QUOTE(airline_acronym), ';',
        'GRANT SELECT, INSERT, DELETE ON project2.', @airplane_model_view_name, ' TO ', QUOTE(airline_acronym), ';'
    );

    PREPARE stmt FROM @create_airline_view;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    PREPARE stmt FROM @grant_airline;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;
//

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

   CALL create_airline_views(airline);
END; 
//
