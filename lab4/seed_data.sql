
-- =========================
-- Начальное наполнение БД
-- =========================

-- Зал
INSERT INTO gym (gym_name, address, phone_num)
VALUES ('Iron Temple Center', 'ул. Ленина, 10', '+37529111223');

-- Должности
INSERT INTO job_position (job_pos_id, job_pos_name) VALUES
('administrator', 'Администратор'),
('accountant', 'Бухгалтер'),
('trainer', 'Персональный тренер'),
('massagist', 'Массажист');

-- Сотрудники
INSERT INTO worker (
    full_name, passport_series, passport_number, sex, experience, birthday, hire_date
) VALUES
('Иванов Илья Сергеевич', 'MP', '1000001', 'male', 6, '1992-04-12 00:00:00', '2021-03-01'),
('Петрова Анна Викторовна', 'MP', '1000002', 'female', 8, '1989-07-23 00:00:00', '2020-06-15'),
('Сидоров Максим Олегович', 'MP', '1000003', 'male', 5, '1995-01-17 00:00:00', '2022-02-10'),
('Орлов Денис Павлович', 'MP', '1000004', 'male', 9, '1988-08-19 00:00:00', '2019-05-20');

-- Роли сотрудников
INSERT INTO worker_role (worker_id, job_pos_id)
SELECT worker_id, 'administrator'
FROM worker
WHERE passport_number = '1000001';

INSERT INTO worker_role (worker_id, job_pos_id)
SELECT worker_id, 'accountant'
FROM worker
WHERE passport_number = '1000002';

INSERT INTO worker_role (worker_id, job_pos_id)
SELECT worker_id, 'trainer'
FROM worker
WHERE passport_number = '1000003';

INSERT INTO worker_role (worker_id, job_pos_id)
SELECT worker_id, 'massagist'
FROM worker
WHERE passport_number = '1000004';

-- Сотрудники и тренеры
INSERT INTO employee (employee_id)
SELECT worker_id FROM worker;

INSERT INTO trainer (trainer_id, grade)
SELECT worker_id, 'expert'
FROM worker
WHERE passport_number = '1000003';

-- Место работы
INSERT INTO employee_place_of_work (worker_id, gym_id)
SELECT w.worker_id, g.gym_id
FROM worker w
JOIN gym g ON g.gym_name = 'Iron Temple Center';

-- Зоны
INSERT INTO gym_zone (zone_id, gym_id, zone_name, description)
SELECT 1, gym_id, 'Тренажёрный зал', 'Основная тренировочная зона'
FROM gym
WHERE gym_name = 'Iron Temple Center';

-- Клиенты
INSERT INTO client (
    full_name, passport_series, passport_number, sex, phone_num, birthday, enroll_date
) VALUES
('Алексеев Кирилл Андреевич', 'KH', '2000001', 'male', '+37529700112', '2000-02-14 00:00:00', '2024-01-10'),
('Михайлова Дарья Сергеевна', 'KH', '2000002', 'female', '+37529700334', '1998-06-30 00:00:00', '2024-02-05');

-- Абонемент
INSERT INTO abonement (abon_type, date_start, date_end)
VALUES ('smart', '2026-03-01 00:00:00', '2026-03-31 23:59:59');

-- Договор
INSERT INTO contract (client_id, admin_employee_id, summ, abon_id, date_sign)
SELECT
    c.client_id,
    w.worker_id,
    120.00,
    a.abon_id,
    '2026-03-01 10:00:00'
FROM client c, worker w, abonement a
WHERE c.passport_number = '2000001'
  AND w.passport_number = '1000001'
  AND a.abon_type = 'smart';

-- План оплат
INSERT INTO payment_plan (contract_id)
SELECT contract_id FROM contract;

-- Платёж за абонемент
INSERT INTO payment_document (
    account_number, summ, description, accountant_employee_id, date_sign, client_id
)
SELECT
    'ACC-0001',
    120.00,
    'Оплата абонемента Smart',
    w.worker_id,
    '2026-03-01 10:15:00',
    c.client_id
FROM worker w, client c
WHERE w.passport_number = '1000002'
  AND c.passport_number = '2000001';

-- Связь договора и платежа
INSERT INTO contract_payment (pay_doc_id, contract_id)
SELECT pd.pay_doc_id, ct.contract_id
FROM payment_document pd
JOIN contract ct ON ct.client_id = pd.client_id
WHERE pd.account_number = 'ACC-0001';

-- Персональная тренировка
INSERT INTO training (
    trainer_id, zone_id, gym_id, time_start, time_end, training_type
)
SELECT
    w.worker_id,
    gz.zone_id,
    gz.gym_id,
    '2026-03-12 18:00:00',
    '2026-03-12 19:00:00',
    'personal'
FROM worker w
JOIN gym g ON g.gym_name = 'Iron Temple Center'
JOIN gym_zone gz ON gz.gym_id = g.gym_id AND gz.zone_id = 1
WHERE w.passport_number = '1000003';

-- Посещение зала
INSERT INTO visit (client_id, gym_id, time_enter, time_exit)
SELECT
    c.client_id,
    g.gym_id,
    '2026-03-11 08:00:00',
    '2026-03-11 09:30:00'
FROM client c
JOIN gym g ON g.gym_name = 'Iron Temple Center'
WHERE c.passport_number = '2000001';

-- Отдельная оплата массажа
INSERT INTO payment_document (
    account_number, summ, description, accountant_employee_id, date_sign, client_id
)
SELECT
    'ACC-0002',
    50.00,
    'Оплата массажа',
    w.worker_id,
    '2026-03-14 13:10:00',
    c.client_id
FROM worker w, client c
WHERE w.passport_number = '1000002'
  AND c.passport_number = '2000002';

-- Услуга массажа
INSERT INTO service (
    service_type, description, pay_doc_id, specialist_id, client_id, time_start, time_end
)
SELECT
    'classic_massage',
    'Классический массаж',
    pd.pay_doc_id,
    w.worker_id,
	c.client_id,
    '2026-03-14 13:30:00',
    '2026-03-14 14:15:00'
FROM payment_document pd, client c
JOIN worker w ON w.passport_number = '1000004'
WHERE pd.account_number = 'ACC-0002'
	AND c.passport_number = '2000001';