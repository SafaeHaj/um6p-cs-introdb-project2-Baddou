USE project2;

-- CALL CancelFlight('SI11279');

-- CALL UpgradeSeatClass('4', 'economy');
-- SELECT * FROM Ticket WHERE tid = '4';

CALL AddTicketToReservation(
	"7025588889",
     1,
     "DQF741",
    '455412124587784516',
     'dfh4512',
   'Gold',
    'first'
);

select *
from Ticket
WHERE tid='7025588889';

