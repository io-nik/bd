-- Второй запрос предназначен для анализа загруженности тренеров.

-- Отчёт должен содержать ФИО тренера, его грейд, спортцентры, в которых он работает, 
-- количество проведённых персональных тренировок, количество групповых занятий, общее 
-- тренировочное время и среднюю загрузку по месяцам выбранного года.

WITH trainers_info AS (
	SELECT w.worker_id, full_name, t.grade, STRING_AGG(g.address, ', ') AS gyms, 
		COUNT(CASE WHEN tr.training_type = 'personal' THEN 1 END),
		COUNT(CASE WHEN tr.training_type = 'group' THEN 1 END), -- SUM(....)
		SUM(tr.time_end - tr.time_start)
	FROM worker w
	JOIN trainer t ON w.worker_id = t.trainer_id
	LEFT JOIN employee_place_of_work epw ON w.worker_id = epw.worker_id
	LEFT JOIN gym g ON epw.gym_id = g.gym_id
	LEFT JOIN training tr ON t.trainer_id = tr.trainer_id
	
	GROUP BY w.worker_id, t.grade
),
monthly_load AS (
	SELECT 
		t.trainer_id, EXTRACT(MONTH FROM tr.time_start) AS train_month, 
		SUM(tr.time_end - tr.time_start) AS train_time
	FROM trainer t
	LEFT JOIN training tr ON tr.trainer_id = t.trainer_id
	WHERE EXTRACT(YEAR FROM tr.time_start) = 2026
	GROUP BY t.trainer_id, train_month
),
sum_by_month AS (
	SELECT trainer_id, AVG(train_time) AS avg_train_time
	FROM monthly_load
	GROUP BY trainer_id
)
SELECT ti.* , sm.avg_train_time
FROM trainers_info ti
LEFT JOIN sum_by_month sm ON sm.trainer_id = ti.worker_id
