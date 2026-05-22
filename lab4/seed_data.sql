-- =========================
-- Начальное наполнение БД
-- =========================

-- Залы
INSERT INTO gym (gym_name, address, phone_num) VALUES
('Iron Temple Center', 'ул. Ленина, 10', '+37529111223'),
('Forma Hall', 'пр. Победителей, 25', '+37529111224');

-- Должности
INSERT INTO job_position (job_pos_id, job_pos_name) VALUES
('administrator', 'Администратор'),
('accountant', 'Бухгалтер'),
('trainer', 'Персональный тренер'),
('massagist', 'Массажист'),
('nutritionist', 'Нутрициолог'),
('instructor', 'Инструктор');

-- Сотрудники
INSERT INTO worker (
    full_name, passport_series, passport_number, sex, experience, birthday, hire_date
) VALUES
('Иванов Илья Сергеевич', 'MP', '1000001', 'male', 6, '1992-04-12 00:00:00', '2021-03-01'),
('Петрова Анна Викторовна', 'MP', '1000002', 'female', 8, '1989-07-23 00:00:00', '2020-06-15'),
('Сидоров Максим Олегович', 'MP', '1000003', 'male', 5, '1995-01-17 00:00:00', '2022-02-10'),
('Орлов Денис Павлович', 'MP', '1000004', 'male', 9, '1988-08-19 00:00:00', '2019-05-20'),
('Кузнецова Мария Игоревна', 'MP', '1000005', 'female', 4, '1996-05-11 00:00:00', '2023-01-12'),
('Смирнов Артём Викторович', 'MP', '1000006', 'male', 7, '1991-09-09 00:00:00', '2020-11-01');

-- Роли сотрудников
INSERT INTO worker_role (worker_id, job_pos_id)
SELECT worker_id, 'administrator' FROM worker WHERE passport_number = '1000001';
INSERT INTO worker_role (worker_id, job_pos_id)
SELECT worker_id, 'accountant' FROM worker WHERE passport_number = '1000002';
INSERT INTO worker_role (worker_id, job_pos_id)
SELECT worker_id, 'trainer' FROM worker WHERE passport_number = '1000003';
INSERT INTO worker_role (worker_id, job_pos_id)
SELECT worker_id, 'massagist' FROM worker WHERE passport_number = '1000004';
INSERT INTO worker_role (worker_id, job_pos_id)
SELECT worker_id, 'nutritionist' FROM worker WHERE passport_number = '1000005';
INSERT INTO worker_role (worker_id, job_pos_id)
SELECT worker_id, 'instructor' FROM worker WHERE passport_number = '1000006';

-- Employee / trainer
INSERT INTO employee (employee_id)
SELECT worker_id FROM worker
WHERE passport_number IN ('1000001', '1000002', '1000004', '1000005', '1000006');

INSERT INTO trainer (trainer_id, grade)
SELECT worker_id, 'expert'
FROM worker
WHERE passport_number = '1000003';

-- Места работы
INSERT INTO employee_place_of_work (worker_id, gym_id)
SELECT w.worker_id, g.gym_id
FROM worker w
JOIN gym g ON g.gym_name = 'Iron Temple Center'
WHERE w.passport_number IN ('1000001', '1000002', '1000003', '1000004');

INSERT INTO employee_place_of_work (worker_id, gym_id)
SELECT w.worker_id, g.gym_id
FROM worker w
JOIN gym g ON g.gym_name = 'Forma Hall'
WHERE w.passport_number IN ('1000005', '1000006');

-- Зоны
INSERT INTO gym_zone (zone_id, gym_id, zone_name, description)
SELECT 1, gym_id, 'Тренажёрный зал', 'Основная тренировочная зона'
FROM gym
WHERE gym_name = 'Iron Temple Center';

INSERT INTO gym_zone (zone_id, gym_id, zone_name, description)
SELECT 2, gym_id, 'Зал групповых занятий', 'Зона для групповых программ'
FROM gym
WHERE gym_name = 'Iron Temple Center';

INSERT INTO gym_zone (zone_id, gym_id, zone_name, description)
SELECT 1, gym_id, 'Кардио-зона', 'Беговые дорожки и велотренажёры'
FROM gym
WHERE gym_name = 'Forma Hall';

-- Клиенты
INSERT INTO client (
    full_name, passport_series, passport_number, sex, phone_num, birthday, enroll_date
) VALUES
('Алексеев Кирилл Андреевич', 'KH', '2000001', 'male', '+37529700112', '2000-02-14 00:00:00', '2024-01-10'),
('Михайлова Дарья Сергеевна', 'KH', '2000002', 'female', '+37529700334', '1998-06-30 00:00:00', '2024-02-05'),
('Новиков Егор Алексеевич', 'KH', '2000003', 'male', '+37529700556', '1997-10-21 00:00:00', '2024-03-01');

-- Абонементы
INSERT INTO abonement (abon_type, date_start, date_end) VALUES
('smart',    '2026-03-01 00:00:00', '2026-05-31 23:59:59'),
('infinity', '2026-03-10 00:00:00', '2026-09-10 23:59:59');

-- Договоры
INSERT INTO contract (
    client_id, admin_employee_id, summ, duration_month, contract_type, installment_month, abon_id, date_sign
)
SELECT
    c.client_id,
    w.worker_id,
    120.00,
    3,
    'one-time-pay',
    NULL,
    a.abon_id,
    '2026-03-01 10:00:00'
FROM client c, worker w, abonement a
WHERE c.passport_number = '2000001'
  AND w.passport_number = '1000001'
  AND a.abon_type = 'smart'
  AND a.date_start = '2026-03-01 00:00:00';

INSERT INTO contract (
    client_id, admin_employee_id, summ, duration_month, contract_type, installment_month, abon_id, date_sign
)
SELECT
    c.client_id,
    w.worker_id,
    180.00,
    6,
    'installment',
    3,
    a.abon_id,
    '2026-03-10 11:00:00'
FROM client c, worker w, abonement a
WHERE c.passport_number = '2000002'
  AND w.passport_number = '1000001'
  AND a.abon_type = 'infinity'
  AND a.date_start = '2026-03-10 00:00:00';

-- Платёжные документы по договорам
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

INSERT INTO payment_document (
    account_number, summ, description, accountant_employee_id, date_sign, client_id
)
SELECT
    'ACC-0002',
    60.00,
    'Первый взнос по абонементу Infinity',
    w.worker_id,
    '2026-03-10 11:20:00',
    c.client_id
FROM worker w, client c
WHERE w.passport_number = '1000002'
  AND c.passport_number = '2000002';

INSERT INTO payment_document (
    account_number, summ, description, accountant_employee_id, date_sign, client_id
)
SELECT
    'ACC-0003',
    60.00,
    'Второй взнос по абонементу Infinity',
    w.worker_id,
    '2026-04-10 11:20:00',
    c.client_id
FROM worker w, client c
WHERE w.passport_number = '1000002'
  AND c.passport_number = '2000002';

-- Связь договора и платежей
INSERT INTO contract_payment (pay_doc_id, contract_id)
SELECT pd.pay_doc_id, ct.contract_id
FROM payment_document pd
JOIN contract ct ON ct.client_id = pd.client_id
WHERE pd.account_number = 'ACC-0001'
  AND ct.contract_type = 'one-time-pay';

INSERT INTO contract_payment (pay_doc_id, contract_id)
SELECT pd.pay_doc_id, ct.contract_id
FROM payment_document pd
JOIN contract ct ON ct.client_id = pd.client_id
WHERE pd.account_number = 'ACC-0002'
  AND ct.contract_type = 'installment';

INSERT INTO contract_payment (pay_doc_id, contract_id)
SELECT pd.pay_doc_id, ct.contract_id
FROM payment_document pd
JOIN contract ct ON ct.client_id = pd.client_id
WHERE pd.account_number = 'ACC-0003'
  AND ct.contract_type = 'installment';

-- Платёжный план
INSERT INTO payment_plan (
    contract_id, payment_num, due_date, planned_amount, is_paid, pay_doc_id
)
SELECT
    ct.contract_id,
    1,
    '2026-03-01 23:59:59',
    120.00,
    true,
    pd.pay_doc_id
FROM contract ct
JOIN payment_document pd ON pd.client_id = ct.client_id
WHERE ct.contract_type = 'one-time-pay'
  AND pd.account_number = 'ACC-0001';

INSERT INTO payment_plan (
    contract_id, payment_num, due_date, planned_amount, is_paid, pay_doc_id
)
SELECT
    ct.contract_id,
    1,
    '2026-03-10 23:59:59',
    60.00,
    true,
    pd.pay_doc_id
FROM contract ct
JOIN payment_document pd ON pd.client_id = ct.client_id
WHERE ct.contract_type = 'installment'
  AND pd.account_number = 'ACC-0002';

INSERT INTO payment_plan (
    contract_id, payment_num, due_date, planned_amount, is_paid, pay_doc_id
)
SELECT
    ct.contract_id,
    2,
    '2026-04-10 23:59:59',
    60.00,
    true,
    pd.pay_doc_id
FROM contract ct
JOIN payment_document pd ON pd.client_id = ct.client_id
WHERE ct.contract_type = 'installment'
  AND pd.account_number = 'ACC-0003';

INSERT INTO payment_plan (
    contract_id, payment_num, due_date, planned_amount, is_paid, pay_doc_id
)
SELECT
    ct.contract_id,
    3,
    '2026-05-10 23:59:59',
    60.00,
    false,
    NULL
FROM contract ct
WHERE ct.contract_type = 'installment';

-- Тренировки
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

INSERT INTO training (
    trainer_id, zone_id, gym_id, time_start, time_end, training_type
)
SELECT
    w.worker_id,
    gz.zone_id,
    gz.gym_id,
    '2026-03-15 19:00:00',
    '2026-03-15 20:00:00',
    'group'
FROM worker w
JOIN gym g ON g.gym_name = 'Iron Temple Center'
JOIN gym_zone gz ON gz.gym_id = g.gym_id AND gz.zone_id = 2
WHERE w.passport_number = '1000003';

-- Посещения зала
INSERT INTO visit (client_id, gym_id, time_enter, time_exit)
SELECT
    c.client_id,
    g.gym_id,
    '2026-03-11 08:00:00',
    '2026-03-11 09:30:00'
FROM client c
JOIN gym g ON g.gym_name = 'Iron Temple Center'
WHERE c.passport_number = '2000001';

INSERT INTO visit (client_id, gym_id, time_enter, time_exit)
SELECT
    c.client_id,
    g.gym_id,
    '2026-03-16 18:10:00',
    '2026-03-16 19:40:00'
FROM client c
JOIN gym g ON g.gym_name = 'Iron Temple Center'
WHERE c.passport_number = '2000002';

-- Дополнительные оплаты
INSERT INTO payment_document (
    account_number, summ, description, accountant_employee_id, date_sign, client_id
)
SELECT
    'ACC-0004',
    50.00,
    'Оплата массажа',
    w.worker_id,
    '2026-03-14 13:10:00',
    c.client_id
FROM worker w, client c
WHERE w.passport_number = '1000002'
  AND c.passport_number = '2000002';

INSERT INTO payment_document (
    account_number, summ, description, accountant_employee_id, date_sign, client_id
)
SELECT
    'ACC-0005',
    45.00,
    'Оплата персональной тренировки',
    w.worker_id,
    '2026-03-18 12:00:00',
    c.client_id
FROM worker w, client c
WHERE w.passport_number = '1000002'
  AND c.passport_number = '2000003';

-- Услуги
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
WHERE pd.account_number = 'ACC-0004'
  AND c.passport_number = '2000002';

-- Посещения тренировок
INSERT INTO training_visit (
    client_id, training_id, training_reason, contract_id, pay_doc_id
)
SELECT
    c.client_id,
    t.training_id,
    'abonement',
    ct.contract_id,
    NULL
FROM client c
JOIN contract ct ON ct.client_id = c.client_id
JOIN training t ON t.training_type = 'group'
WHERE c.passport_number = '2000002';

INSERT INTO training_visit (
    client_id, training_id, training_reason, contract_id, pay_doc_id
)
SELECT
    c.client_id,
    t.training_id,
    'purchase',
    NULL,
    pd.pay_doc_id
FROM client c
JOIN payment_document pd ON pd.client_id = c.client_id
JOIN training t ON t.training_type = 'personal'
WHERE c.passport_number = '2000003'
  AND pd.account_number = 'ACC-0005';
