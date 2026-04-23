-- Общие минимальные данные для всех 4 проверок
-- Предполагается пустая БД после db_creation.sql

-- 1. Зал и зоны
INSERT INTO gym (gym_name, address, phone_num)
VALUES ('Test Gym', 'Test address 1', '+79990000001');

INSERT INTO gym_zone (zone_id, gym_id, zone_name, description)
VALUES
(1, 1, 'Zone A', 'First zone'),
(2, 1, 'Zone B', 'Second zone');

-- 2. Работники: 1 - администратор, 2 и 3 - тренеры
INSERT INTO worker (
    full_name, passport_series, passport_number,
    sex, experience, birthday, hire_date
)
VALUES
('Admin One',   'AA11', '100001', 'female', 3, '1998-01-01 00:00:00', '2022-01-10'),
('Trainer One', 'AA11', '100002', 'male',   5, '1995-02-02 00:00:00', '2020-01-10'),
('Trainer Two', 'AA11', '100003', 'female', 6, '1994-03-03 00:00:00', '2020-01-10');

INSERT INTO trainer (trainer_id, grade)
VALUES
(2, 'expert'),
(3, 'master');

-- 3. Клиенты
INSERT INTO client (
    full_name, passport_series, passport_number,
    sex, phone_num, birthday, enroll_date
)
VALUES
('Client One',   'BB22', '200001', 'male',   '+79990000011', '2001-01-01 00:00:00', '2024-01-10'),
('Client Two',   'BB22', '200002', 'female', '+79990000012', '2002-02-02 00:00:00', '2024-01-10'),
('Client Three', 'BB22', '200003', 'male',   '+79990000013', '2003-03-03 00:00:00', '2024-01-10'),
('Client Four',  'BB22', '200004', 'female', '+79990000014', '2004-04-04 00:00:00', '2024-01-10');

-- 4. Абонементы для 1-го триггера
INSERT INTO abonement (abon_type, date_start, date_end)
VALUES
('smart', '2026-05-01 00:00:00', '2027-05-01 00:00:00'),
('smart', '2026-06-01 00:00:00', '2027-06-01 00:00:00');