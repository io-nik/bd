-- Подготовка: создаём персональную тренировку для переноса
INSERT INTO training (
    trainer_id, zone_id, gym_id,
    time_start, time_end, training_type
)
VALUES (
    2, 2, 1,
    '2026-06-02 10:00:00', '2026-06-02 11:00:00',
    'personal'
);

INSERT INTO training_visit (client_id, training_id, training_reason)
VALUES (1, 3, 'abonement');

-- Позитивный тест:
CALL move_personal_train(
    2,                                  -- trainer_id
    1,                                  -- client_id
    TIMESTAMP '2026-06-02 10:00:00',              -- old start
    TIMESTAMP'2026-06-02 11:00:00',              -- old end
    TIMESTAMP'2026-06-02 14:00:00',              -- new start
    TIMESTAMP'2026-06-02 15:00:00'               -- new end
);

SELECT training_id, time_start, time_end
FROM training
WHERE training_id = 3;

-- Подготовка конфликта: ещё одна тренировка у того же тренера
INSERT INTO training (
    trainer_id, zone_id, gym_id,
    time_start, time_end, training_type
)
VALUES (
    2, 1, 1,
    '2026-06-02 16:00:00', '2026-06-02 17:00:00',
    'group'
);

-- Негативный тест:
-- попытка перенести в интервал, где тренер уже занят
CALL move_personal_train(
    2,
    1,
    '2026-06-02 14:00:00',
    '2026-06-02 15:00:00',
    '2026-06-02 16:30:00',
    '2026-06-02 17:30:00'
);

-- После ошибки время должно остаться прежним
SELECT training_id, time_start, time_end
FROM training
WHERE training_id = 3;