-- Пятый запрос формирует рейтинг клиентов по активности.

-- В отчёте отображаются клиенты с наибольшим числом посещений, суммой оплаченных услуг,
-- количеством тренировок и использованием дополнительных сервисов за выбранный период.

WITH visit_count AS ( -- числом посещений
	SELECT v.client_id, COUNT (*) AS visit_count
	FROM visit v
	WHERE DATE(v.time_enter) BETWEEN DATE '2025-01-01' AND DATE '2025-12-31'
	GROUP BY v.client_id
),
pers_sum AS ( -- суммой оплаченных услуг
	SELECT pd.client_id, SUM(pd.summ) AS money_spent
	FROM payment_document pd
	WHERE DATE(pd.date_sign) BETWEEN DATE '2025-01-01' AND DATE '2025-12-31'
	GROUP BY pd.client_id
),
pers_train AS ( -- количеством тренировок
	SELECT tv.client_id, COUNT (*) AS trains_in
	FROM training_visit tv
	LEFT JOIN training tr ON tv.training_id = tr.training_id
	WHERE DATE(tr.time_start) BETWEEN DATE '2025-01-01' AND DATE '2025-12-31'
	GROUP BY tv.client_id
),
pers_serv AS (
	SELECT s.client_id, COUNT(*) AS servs_in
	FROM service s
	WHERE DATE(s.time_start) BETWEEN DATE '2025-01-01' AND DATE '2025-12-31'
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
ORDER BY visit_count DESC, money_spent DESC, trains_in DESC, servs_in DESC


