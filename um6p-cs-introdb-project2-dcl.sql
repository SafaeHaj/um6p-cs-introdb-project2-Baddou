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
    DECLARE user_name VARCHAR(32);
    SET user_name = REPLACE( REPLACE(user_email, '@',''), '.', '');

    SET @reservation_view = CONCAT(user_name, 'ReservationView');
    SET @passenger_view = CONCAT(user_name, 'PassengerView');

    SET @create_reservation_view = CONCAT(
        'CREATE VIEW ', reservation_view, ' AS
        SELECT *
        FROM Reservation R JOIN User_ U
        ON R.email = U.uemail
        WHERE U.uemail = ', QUOTE(user_email), ';'
    );

    SET @create_passenger_view = CONCAT(
        'CREATE VIEW ', passenger_view, ' AS 
        SELECT *
        FROM Passenger P JOIN Ticket T ON T.passportID = P.passportID
        JOIN Reservation R ON R.rid = T.rid
        JOIN User_ U ON U.uemail = R.email
        WHERE U.uemail = ', QUOTE(user_email), ';'
    );

    SET @grant_reservation_user = CONCAT('GRANT SELECT, INSERT, UPDATE, DELETE ON project2.', @reservation_view, ' TO ',user_name, ';');
    SET @grant_passenger_user = CONCAT('GRANT SELECT, INSERT, UPDATE, DELETE ON project2.', @passenger_view, ' TO ',user_name, ';');

    PREPARE create_rstmt FROM @create_reservation_view;
    EXECUTE create_rstmt;
    DEALLOCATE PREPARE create_rstmt;

    PREPARE create_pstmt FROM @create_passenger_view;
    EXECUTE create_pstmt;
    DEALLOCATE PREPARE create_pstmt;

    PREPARE grant_rstmt FROM @grant_reservation_user;
    EXECUTE grant_rstmt;
    DEALLOCATE PREPARE grant_rstmt;

    PREPARE grant_pstmt FROM @grant_passenger_user;
    EXECUTE grant_pstmt;
    DEALLOCATE PREPARE grant_pstmt;
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
    SET @drop_query = CONCAT('DROP USER ', QUOTE(user_name), ';');

    PREPARE revoke_stmt FROM @revoke_query;
    EXECUTE revoke_stmt;
    DEALLOCATE PREPARE revoke_stmt;

    PREPARE drop_stmt FROM @drop_query;
    EXECUTE drop_stmt;
    DEALLOCATE PREPARE drop_stmt;
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

    SET @create_airplane_view = CONCAT(
        'CREATE VIEW ', @airplane_view_name, ' AS
        SELECT *
        FROM Airplane
        WHERE Airplane.airline = ', QUOTE(airline)
    );

    SET @create_airplane_model_view = CONCAT(
        'CREATE VIEW ', @airplane_model_view_name, ' AS
        SELECT *
        FROM AirplaneModel
        JOIN Airplane ON Airplane.model = AirplaneModel.model
        WHERE AirplaneModel.airline = ', QUOTE(airline)
    );

    SET @grant_airplane_view = CONCAT(
        'GRANT SELECT, INSERT, DELETE ON project2.', airplane_view_name, ' TO ', QUOTE(airline_acronym), ';'
    );

    SET @grant_airplane_model_view = CONCAT(
        'GRANT SELECT, INSERT, DELETE ON project2.', airplane_model_view_name, ' TO ', QUOTE(airline_acronym), ';'
    );

    PREPARE create_airplane_stmt FROM @create_airplane_view;
    EXECUTE create_airplane_stmt;
    DEALLOCATE PREPARE create_airplane_stmt;

    PREPARE create_airplane_model_stmt FROM @create_airplane_model_view;
    EXECUTE create_airplane_model_stmt;
    DEALLOCATE PREPARE create_airplane_model_stmt;

    PREPARE grant_airplane_stmt FROM @grant_airplane_view;
    EXECUTE grant_airplane_stmt;
    DEALLOCATE PREPARE grant_airplane_stmt;

    PREPARE grant_airplane_model_stmt FROM @grant_airplane_model_view;
    EXECUTE grant_airplane_model_stmt;
    DEALLOCATE PREPARE grant_airplane_model_stmt;
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
