BEGIN;

UPDATE client
SET phone_num = '+71111111111',
	passport_number = '0000000'
WHERE full_name = 'Джон Смит Иванович';

COMMIT;
