-- Первый запрос должен формировать отчёт по продажам абонементов.

-- В отчёте необходимо отразить тип абонемента, срок действия, количество оформленных 
-- договоров, общую сумму продаж, сумму оплаченных средств, количество договоров с 
-- рассрочкой, а также средний размер платежа по каждому типу абонемента.

-- кол-во договоров бессмысленно: один договор - один абонемент

WITH payment_stats AS (
	SELECT c.contract_id, c.abon_id, c.summ AS contract_sum,
		SUM(pd.summ) AS paid_sum, AVG(pd.summ) AS avg_payment,
		CASE WHEN COUNT(pp.pay_plan_id) > 0 THEN 1 ELSE 0 END AS is_pay_plan
		-- если пей_планов больше нуля у договора, то у него есть пей_план
	FROM contract c
	LEFT JOIN contract_payment cp ON c.contract_id = cp.contract_id
	LEFT JOIN payment_document pd ON cp.pay_doc_id = pd.pay_doc_id
	LEFT JOIN payment_plan pp ON c.contract_id = pp.contract_id
	GROUP BY c.contract_id, c.abon_id, c.summ
)
SELECT
	a.abon_id, a.abon_type, a.date_start, a.date_end, 
	COUNT(ps.contract_id) AS contract_count,
	SUM(ps.is_pay_plan) AS is_pay_plan, SUM(ps.contract_sum) AS cost, 
	COALESCE(SUM(ps.paid_sum), 0) AS paid, AVG(ps.avg_payment) AS avg_payment
FROM abonement a
JOIN payment_stats ps ON ps.abon_id = a.abon_id
GROUP BY a.abon_id, a.date_start, a.date_end
ORDER BY a.abon_id



