CREATE ROLE 'user', 'airline', 'admin';

GRANT ALL ON project2.Flight  TO 'airline';
GRANT ALL ON project2.Airplane  TO 'airline';
GRANT SELECT ON project2.Checks TO 'admin';
GRANT ALL ON project2.Reservation TO 'admin';
GRANT SELECT ON project2.Flight TO 'user';

DELIMITER //
CREATE PROCEDURE CreateReservationView(IN user_email VARCHAR(32))
BEGIN
	DECLARE @view_name AS VARCHAR(46)
	DECLARE @sql_query AS VARCHAR(164)
	SET @view_name = CONCAT(SUBSTRING_INDEX(user_email, @, 1), 'ReservationView');
	SET @sql_query = CONCAT('CREATE VIEW', @view_name, 'AS
		SELECT rid, rdate, confirmDate
		FROM Reservation
		JOIN User
		ON Reservation.uemail = User.uemail
		WHERE User.uemail = ', QUOTE(user_email), ';',
		GRANT INSERT, UPDATE, DELETE ON project2., @view_name, to 'user';);
	PREPARE stmt FROM @sql_query;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END //
DELIMITER;

DELIMITER //
CREATE PROCEDURE CreatePassengerView(IN user_email VARCHAR(32))
BEGIN
	DECLARE @view_name AS VARCHAR(46)
	DECLARE @sql_query AS VARCHAR(164)
	SET @view_name = CONCAT(SUBSTRING_INDEX(user_email, @, 1), 'PassengerView');
	SET @sql_query = CONCAT('CREATE VIEW', @view_name, 'AS 
		CREATE VIEW PassengerView AS
	SELECT passportID, cin, pfirstName AS firstName, plastName AS lastName, phoneNumber, 	pbirthDate AS birthDate
	FROM Passenger
	JOIN Ticket ON Ticket.passportID = Passenger.passportID
	JOIN Reservation ON Reservation.rid = Ticket.rid
	JOIN User ON User.uemail = Reservation.uemail
	WHERE User.uemail = ', QUOTE(user_email), ';',
	GRANT INSERT, UPDATE, DELETE ON project2., @view_name, to 'user';
	);
	PREPARE stmt FROM @sql_query;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END //
DELIMITER;
