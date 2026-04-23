-- Позитивный тест:
CALL create_group_train(
    3,                  -- trainer_id
    1,                  -- gym_id
    2::smallint,                  -- zone_id
    TIMESTAMP '2026-06-01 12:00:00',
    TIMESTAMP '2026-06-01 13:00:00',
    ARRAY[1, 2, 3],
    ARRAY[
        'abonement'::TrainingReason,
        'purchase'::TrainingReason,
        'purchase'::TrainingReason
    ]
);

SELECT
    t.training_id,
    t.training_type,
    COUNT(tv.client_id) AS participants
FROM training t
LEFT JOIN training_visit tv ON tv.training_id = t.training_id
WHERE t.trainer_id = 3
  AND t.time_start = '2026-06-01 12:00:00'
GROUP BY t.training_id, t.training_type;

-- Негативный тест:
-- тот же тренер, пересекающееся время -> должна быть ошибка
CALL create_group_train(
    3,
    1,
    1::smallint,
    TIMESTAMP '2026-06-01 12:30:00',
    TIMESTAMP '2026-06-01 13:30:00',
    ARRAY[4],
    ARRAY['purchase'::TrainingReason]
);

-- После ошибки проверка, что у тренера только одна такая тренировка
SELECT COUNT(*) AS group_trainings_cnt
FROM training
WHERE trainer_id = 3
  AND training_type = 'group';