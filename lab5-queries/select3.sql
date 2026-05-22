-- Третий запрос формирует статистику посещений клиентов.

-- Для каждого клиента необходимо отобразить количество посещений спортзалов,
-- число персональных тренировок, участие в групповых занятиях, использование 
-- дополнительных услуг и общее время нахождения в клубах сети.

WITH client_info AS (
	SELECT c.client_id, 
		COALESCE(SUM(CASE WHEN tr.training_type = 'group' THEN 1 ELSE 0 END), 0)
			AS group_visit, -- участие в групповых занятиях
		COALESCE(COUNT(CASE WHEN tr.training_type = 'personal' THEN 1 END), 0)
			AS pers_visit -- число персональных тренировок
	FROM client c
	LEFT JOIN training_visit tv ON c.client_id = tv.client_id
	LEFT JOIN training tr ON tv.training_id = tr.training_id
	GROUP BY c.client_id
),
counted_visit AS ( -- количество посещений спортзалов
	SELECT client_id, COALESCE(COUNT(*), 0) AS visit_count,
		COALESCE(SUM(v.time_exit - time_enter), INTERVAL '0') AS timings
	FROM visit v
	GROUP BY client_id
),
counted_service AS (
	SELECT client_id, COALESCE(COUNT(*), 0) AS serv_count
	FROM service
	GROUP BY client_id
)
SELECT DISTINCT c.client_id, COALESCE(ci.group_visit, 0) AS group_visit, COALESCE(ci.pers_visit, 0),
	COALESCE(cv.visit_count, 0), COALESCE(cs.serv_count, 0), 
	COALESCE(cv.timings, INTERVAL '0')
FROM client c
LEFT JOIN client_info ci ON c.client_id = ci.client_id
LEFT JOIN counted_visit cv ON c.client_id = cv.client_id
LEFT JOIN counted_service cs ON c.client_id = cs.client_id
ORDER BY c.client_id
