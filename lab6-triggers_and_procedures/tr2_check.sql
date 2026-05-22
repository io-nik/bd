-- Позитивный тест:
-- создаём персональную тренировку и записываем первого клиента

INSERT INTO training (
    trainer_id, zone_id, gym_id,
    time_start, time_end, training_type
)
VALUES (
    3, 1, 1,
    '2026-06-01 10:00:00', '2026-06-01 11:00:00',
    'personal'
);

INSERT INTO training_visit (client_id, training_id, training_reason)
VALUES (1, 3, 'abonement');

SELECT training_id, COUNT(*) AS participants
FROM training_visit
WHERE training_id = 1
GROUP BY training_id;

-- Негативный тест:
-- вторая запись на ту же персональную тренировку должна дать ошибку

INSERT INTO training_visit (client_id, training_id, training_reason)
VALUES (2, 3, 'purchase');

-- После ошибки можно проверить, что участников всё ещё 1
SELECT training_id, COUNT(*) AS participants
FROM training_visit
WHERE training_id = 1
GROUP BY training_id;