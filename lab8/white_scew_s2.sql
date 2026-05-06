BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT COUNT(*)
FROM payment_plan
WHERE contract_id = 1 AND is_paid = false;

UPDATE payment_plan
SET is_paid = true
WHERE contract_id = 1 AND payment_num = 45;

COMMIT;
