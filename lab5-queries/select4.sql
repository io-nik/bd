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
	FROM (
		SELECT t.training_id, t.training_type
		FROM training t
		WHERE t.training_type IN ('personal', 'group')
	) t
	JOIN training_visit tv ON t.training_id = tv.training_id
	LEFT JOIN contract c ON tv.contract_id = c.contract_id
	LEFT JOIN payment_document pd ON tv.pay_doc_id = pd.pay_doc_id
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
FROM glue_all           -- общая сумма по строкам + округление до 2 знаков
