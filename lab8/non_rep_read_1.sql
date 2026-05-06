INSERT INTO client (full_name, passport_series, passport_number, sex, phone_num, 
					birthday, enroll_date) VALUES 
	('Джон Смит Иванович', 'SA', '1489350', 'male', '+78005553535', '1996-02-11 00:00:00', '2023-08-10');

BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT c.*
FROM client c
WHERE c.full_name = 'Джон Смит Иванович';

---- execute non_rep_read_s2 fully

SELECT c.*
FROM client c
WHERE c.full_name = 'Джон Смит Иванович';

COMMIT;