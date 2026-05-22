-- Позитивный тест:
-- договор в рассрочку на 3 месяца -> должно появиться 3 строки в payment_plan

INSERT INTO abonement (abon_type, date_start, date_end)
VALUES ('smart', '2026-04-21 00:00:00', '2027-04-21 00:00:00');

INSERT INTO contract (
	client_id, admin_employee_id, summ,
	duration_month, contract_type, installment_month,
	abon_id, date_sign
)
VALUES (1, 1, 12000.00, 12, 'installment', 3, 3, '2026-04-21 10:00:00');

SELECT
	contract_id, COUNT(*) AS payment_count
FROM payment_plan
WHERE contract_id = 3
GROUP BY contract_id;


-- Негативный тест:
-- обычная оплата -> план платежей создаваться не должен

INSERT INTO abonement (abon_type, date_start, date_end)
VALUES ('smart', '2026-04-22 00:00:00', '2027-04-22 00:00:00');

INSERT INTO contract (
    client_id, admin_employee_id, summ,
    duration_month, contract_type, installment_month,
    abon_id, date_sign
)
VALUES (
    1, 1, 15000.00,
    12, 'one-time-pay', NULL,
    2, '2026-04-21 11:00:00'
);

SELECT
    c.contract_id,
    c.contract_type,
    COUNT(pp.pay_plan_id) AS payment_count
FROM contract c
LEFT JOIN payment_plan pp ON pp.contract_id = c.contract_id
WHERE c.contract_id IN (3, 4)
GROUP BY c.contract_id, c.contract_type
ORDER BY c.contract_id;