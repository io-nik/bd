BEGIN;

INSERT INTO client (full_name, passport_series, passport_number, sex, phone_num, birthday, enroll_date) VALUES 
('Подставной Дмитрий Дмитриевич', 'MM', '1111111', 'male', '+78005551111', '1996-02-11 00:00:00', '2023-12-30');

INSERT INTO client (full_name, passport_series, passport_number, sex, phone_num, birthday, enroll_date) VALUES 
('Подставной Иван Иванович', 'MM', '2222222', 'male', '+78005552222', '1999-02-11 00:00:00', '2023-12-30');

INSERT INTO client (full_name, passport_series, passport_number, sex, phone_num, birthday, enroll_date) VALUES 
('Подставной Сергей Сергеевич', 'MM', '3333333', 'male', '+78005553333', '1986-02-11 00:00:00', '2023-12-30');

COMMIT;
