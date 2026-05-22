ANALYZE;


EXPLAIN(ANALYZE, BUFFERS)

-- Пятый запрос формирует рейтинг клиентов по активности.

-- В отчёте отображаются клиенты с наибольшим числом посещений, суммой оплаченных услуг,
-- количеством тренировок и использованием дополнительных сервисов за выбранный период.

WITH visit_count AS ( -- числом посещений
	SELECT v.client_id, COUNT (*) AS visit_count
	FROM visit v
	WHERE v.time_enter >= TIMESTAMP '2025-01-01'
		AND v.time_enter < TIMESTAMP '2026-01-01'
	GROUP BY v.client_id
),
pers_sum AS ( -- суммой оплаченных услуг
	SELECT pd.client_id, SUM(pd.summ) AS money_spent
	FROM payment_document pd
	WHERE pd.date_sign >= TIMESTAMP '2025-01-01'
		AND pd.date_sign < TIMESTAMP '2026-01-01'
	GROUP BY pd.client_id
),
pers_train AS ( -- количеством тренировок
	SELECT tv.client_id, COUNT (*) AS trains_in
	FROM training_visit tv
	LEFT JOIN training tr ON tv.training_id = tr.training_id
	WHERE tr.time_start >= TIMESTAMP '2025-01-01'
		AND tr.time_start < TIMESTAMP '2026-01-01'
	GROUP BY tv.client_id
),
pers_serv AS (
	SELECT s.client_id, COUNT(*) AS servs_in
	FROM service s
	WHERE s.time_start >= TIMESTAMP '2025-01-01'
		AND s.time_start < TIMESTAMP '2026-01-01'
	GROUP BY s.client_id
)
SELECT c.client_id, c.full_name, COALESCE(vc.visit_count, 0) AS visit_count,
	COALESCE(ps.money_spent, 0) AS money_spent, COALESCE(pt.trains_in, 0) AS trains_in,
	COALESCE(psu.servs_in, 0) AS servs_in
FROM client c
LEFT JOIN visit_count vc ON c.client_id = vc.client_id
LEFT JOIN pers_sum ps ON c.client_id = ps.client_id
LEFT JOIN pers_train pt ON c.client_id = pt.client_id
LEFT JOIN pers_serv psu ON c.client_id = psu.client_id
ORDER BY visit_count DESC, money_spent DESC, trains_in DESC, servs_in DESC;


EXPLAIN (ANALYZE, BUFFERS)
-- Четвёртый запрос предназначен для анализа финансовых потоков.

-- Отчёт должен включать суммы оплат по абонементам, персональным тренировкам, 
-- групповым занятиям и дополнительным услугам, а также долю каждого направления 
-- в общем доходе сети.
WITH calc_abon AS ( -- абонементам
	SELECT 'abonements' AS money_source, SUM(c.summ) AS amount
	FROM abonement a
	JOIN contract c ON a.abon_id = c.abon_id
),
calc_pg_tr AS ( -- персональным тренировкам & групповым занятиям
	SELECT t.training_type::TEXT AS money_source,
	SUM(CASE WHEN tv.training_reason = 'purchase' THEN pd.summ ELSE 0 END) AS amount -- SUM(CASE WHEN tv.training_reason = 'abonement' THEN c.summ ELSE pd.summ END
	FROM training t
	JOIN training_visit tv ON t.training_id = tv.training_id
		AND tv.training_reason = 'purchase'
	LEFT JOIN payment_document pd ON tv.pay_doc_id = pd.pay_doc_id
	WHERE t.training_type IN ('personal', 'group')
	GROUP BY t.training_type
),
calc_serv AS ( -- дополнительным услугам
	SELECT 'services' AS money_source, SUM(pd.summ) AS amount
	FROM service s
	LEFT JOIN payment_document pd ON s.pay_doc_id = pd.pay_doc_id
),
glue_all AS (
	SELECT ca.* FROM calc_abon ca
	UNION ALL
	SELECT cpt.* FROM calc_pg_tr cpt
	UNION ALL
	SELECT cs.* FROM calc_serv cs
)
SELECT money_source, amount,
	ROUND(amount * 100.0 / SUM(amount) OVER (), 2) AS percent_total
FROM glue_all;           -- общая сумма по строкам + округление до 2 знаков
