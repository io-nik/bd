BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;

SELECT *
FROM client
WHERE enroll_date BETWEEN DATE '2023-08-08' AND DATE '2024-01-01';

----- exetute phan_read_s2 fully

SELECT *
FROM client
WHERE enroll_date BETWEEN DATE '2023-08-08' AND DATE '2024-01-01';

COMMIT;

ROLLBACK;
