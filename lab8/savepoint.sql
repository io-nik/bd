INSERT INTO payment_plan (contract_id, payment_num, due_date, planned_amount, is_paid, pay_doc_id) VALUES 
(3, 111, '2026-01-21 12:18:00', 120.00, false, 100);

SELECT *
FROM payment_plan
WHERE contract_id = 3 AND payment_num = 111;

---------
BEGIN;

UPDATE payment_plan
SET planned_amount = planned_amount + 500
WHERE contract_id = 3 AND payment_num = 111;

SELECT *
FROM payment_plan
WHERE contract_id = 3 AND payment_num = 111;

---------
SAVEPOINT svpnt;


UPDATE payment_plan
SET planned_amount = -99999
WHERE contract_id = 3 AND payment_num = 111;

SELECT *
FROM payment_plan
WHERE contract_id = 3 AND payment_num = 111;

----------
ROLLBACK TO svpnt;

COMMIT;


SELECT *
FROM payment_plan
WHERE contract_id = 3 AND payment_num = 111;