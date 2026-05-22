INSERT INTO client (full_name, passport_series, passport_number, sex, phone_num, birthday, enroll_date) VALUES 
('Засадной Николай Иванович', 'ZZ', '1234567', 'male', '+72222222222', '2000-02-11 00:00:00', '2023-08-10');

INSERT INTO payment_plan (contract_id, payment_num, due_date, planned_amount, is_paid, pay_doc_id) VALUES 
(1, 44, '2024-08-21 22:18:00', 120.00, false, NULL),
(1, 45, '2024-08-21 22:19:00', 130.00, false, NULL);

BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW transaction_isolation;

SELECT COUNT(*)
FROM payment_plan
WHERE contract_id = 1 AND is_Paid = false;

UPDATE payment_plan
SET is_paid = true
WHERE contract_id = 1 AND payment_num = 44;

---- execute white_scew_s2 fully

COMMIT;


SELECT *
FROM payment_plan
WHERE contract_id = 1;