-- Проверки того, что массаж проводит массажист
-- Сейчас один абонемент может иметь НЕСКОЛЬКО договоров


DROP TABLE IF EXISTS worker_role; -- E18
DROP TABLE IF EXISTS contract_payment; -- E17
DROP TABLE IF EXISTS employee; -- E16
DROP TABLE IF EXISTS trainer; -- E15
DROP TABLE IF EXISTS training_visit; -- E14
DROP TABLE IF EXISTS employee_place_of_work; -- E13
DROP TABLE IF EXISTS service; -- E12
DROP TABLE IF EXISTS visit; -- E11
DROP TABLE IF EXISTS training; -- E9
DROP TABLE IF EXISTS gym_zone; -- E10
DROP TABLE IF EXISTS payment_document; -- E8
DROP TABLE IF EXISTS payment_plan; -- E7
DROP TABLE IF EXISTS contract; -- E6
DROP TABLE IF EXISTS abonement; -- E5
DROP TABLE IF EXISTS client; -- E4
DROP TABLE IF EXISTS job_position; -- E3
DROP TABLE IF EXISTS worker; -- E2
DROP TABLE IF EXISTS gym; -- E1

DROP TYPE IF EXISTS GradeType;
DROP TYPE IF EXISTS TrainingReason;
DROP TYPE IF EXISTS ServiceType;
DROP TYPE IF EXISTS TrainingType;
DROP TYPE IF EXISTS AbonementType;
DROP TYPE IF EXISTS JobPosition;
DROP TYPE IF EXISTS Sex;



CREATE TABLE gym ( -- E1
	gym_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	gym_name text NOT NULL,
	address text UNIQUE NOT NULL,
	phone_num varchar(12),
	CONSTRAINT phone_rule CHECK (phone_num ~ '^\+?[0-9]{11}$')
);


CREATE TYPE Sex AS ENUM ('male', 'female');

CREATE TABLE worker ( -- E2
	worker_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	full_name varchar(200) NOT NULL,
	passport_series varchar(8) NOT NULL,
	passport_number varchar(12) NOT NULL,
	sex Sex NOT NULL,
	experience integer NOT NULL,
	birthday timestamp NOT NULL,
	hire_date date NOT NULL,
	CONSTRAINT check_worker_dates CHECK (hire_date > birthday::date),
	CONSTRAINT check_age CHECK (birthday <= hire_date - INTERVAL '18' YEAR),
	CONSTRAINT worker_passport UNIQUE (passport_series, passport_number)
);


CREATE TYPE JobPosition AS ENUM ('administrator', 'accountant', 'instructor', 'trainer',
	'massagist', 'nutritionist');

CREATE TABLE job_position ( -- E3
	job_pos_id JobPosition PRIMARY KEY NOT NULL,
	job_pos_name varchar(200)
);


CREATE TABLE client ( -- E4
	client_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	full_name varchar(200) NOT NULL,
	passport_series varchar(8) NOT NULL,
	passport_number varchar(12) NOT NULL,
	sex Sex NOT NULL,
	phone_num varchar(12),
	birthday timestamp NOT NULL,
	enroll_date date NOT NULL,
	CONSTRAINT check_client_dates CHECK (enroll_date > birthday::date),
	CONSTRAINT phone_rule CHECK (phone_num ~ '^\+?[0-9]{11}$'),
	CONSTRAINT client_passport UNIQUE (passport_series, passport_number)
);


CREATE TYPE AbonementType AS ENUM ('light', 'smart', 'infinity');

CREATE TABLE abonement ( -- E5
	abon_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	abon_type AbonementType NOT NULL,
	date_start timestamp NOT NULL,
	date_end timestamp NOT NULL,
	CONSTRAINT chk_abon_dates CHECK (date_end > date_start)
);


CREATE TABLE contract ( -- E6 dodelat'
	contract_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	client_id integer NOT NULL REFERENCES client(client_id),
	admin_employee_id integer NOT NULL REFERENCES worker(worker_id),
	summ numeric(8, 2) NOT NULL,
	abon_id bigint UNIQUE NOT NULL REFERENCES abonement(abon_id),
	date_sign timestamp NOT NULL,
	CONSTRAINT chk_contract_summ CHECK (summ > 0)
);


CREATE TABLE payment_plan ( -- E7
	pay_plan_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	contract_id bigint UNIQUE NOT NULL REFERENCES contract(contract_id)
);


CREATE TABLE payment_document ( -- E8
	pay_doc_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	account_number varchar(20) NOT NULL,
	summ numeric(8, 2) NOT NULL,
	description text NOT NULL,
	accountant_employee_id int NOT NULL REFERENCES worker(worker_id),
	date_sign timestamp NOT NULL,
	client_id int NOT NULL REFERENCES client(client_id),
	CONSTRAINT chk_pay_doc_sum CHECK (summ > 0)
);


CREATE TABLE gym_zone ( -- E10
	zone_id smallint NOT NULL,
	gym_id int NOT NULL REFERENCES gym(gym_id),
	zone_name varchar(100),
	description text,
	PRIMARY KEY (gym_id, zone_id)
);


CREATE TYPE TrainingType AS ENUM ('personal', 'group', 'split');

CREATE TABLE training ( -- E9
	training_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	trainer_id int NOT NULL, ------------
	zone_id smallint NOT NULL,
	gym_id int NOT NULL,
	time_start timestamp NOT NULL,
	time_end timestamp NOT NULL,
	training_type TrainingType NOT NULL,
	CONSTRAINT fk_trainer_employee FOREIGN KEY (trainer_id) REFERENCES worker(worker_id),
	CONSTRAINT fk_gym_zone_id FOREIGN KEY (gym_id, zone_id) 
		REFERENCES gym_zone(gym_id, zone_id),
	CONSTRAINT chk_training_time CHECK (time_start < time_end)
);


CREATE TABLE visit ( -- E11
	client_id int NOT NULL,
	gym_id int NOT NULL,
	time_enter timestamp NOT NULL,
	time_exit timestamp NOT NULL,
	CONSTRAINT fk_client_id FOREIGN KEY (client_id) REFERENCES client(client_id),
	CONSTRAINT fk_gym_id FOREIGN KEY (gym_id) REFERENCES gym(gym_id),
	CONSTRAINT chk_visit_time CHECK (time_enter < time_exit)
);


CREATE TYPE ServiceType AS ENUM ('sport_massage', 'point_massage', 'classic_massage',
	'spa_massage', 'consultation');

CREATE TABLE service ( -- E12
	service_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	service_type ServiceType NOT NULL,
	description text,
	pay_doc_id bigint NOT NULL,
	specialist_id int NOT NULL, --------------------------------------------------
	client_id int NOT NULL,
	time_start timestamp NOT NULL,
	time_end timestamp NOT NULL,
	CONSTRAINT fk_pay_doc_id FOREIGN KEY (pay_doc_id) REFERENCES payment_document(pay_doc_id),
	CONSTRAINT fk_specialist_id FOREIGN KEY (specialist_id) REFERENCES worker(worker_id),
	CONSTRAINT chk_service_time CHECK (time_start < time_end)
);


CREATE TABLE employee_place_of_work ( -- E13
	worker_id int NOT NULL,
	gym_id int NOT NULL,
	CONSTRAINT fk_worker_id FOREIGN KEY (worker_id) REFERENCES worker(worker_id),
	CONSTRAINT fk_gym_id FOREIGN KEY (gym_id) REFERENCES gym(gym_id)
);


CREATE TYPE TrainingReason AS ENUM ('abonement', 'purchase');

CREATE TABLE training_visit ( -- E14
	client_id int NOT NULL,
	training_id bigint NOT NULL,
	training_reason TrainingReason NOT NULL,
	contract_id bigint, --------------------- Это является внешним ключом?
	pay_doc_id bigint, --------------------- Это является внешним ключом?
	CONSTRAINT fk_client_id FOREIGN KEY (client_id) REFERENCES client(client_id),
	CONSTRAINT fk_training_id FOREIGN KEY (training_id) REFERENCES training(training_id),
	CONSTRAINT fk_contract_id FOREIGN KEY (contract_id) REFERENCES contract(contract_id),
	CONSTRAINT fk_pay_doc_id FOREIGN KEY (pay_doc_id) REFERENCES payment_document(pay_doc_id)
);


CREATE TYPE GradeType AS ENUM ('master', 'expert', 'top');

CREATE TABLE trainer ( -- E15
	trainer_id integer PRIMARY KEY,
	grade GradeType NOT NULL,
    CONSTRAINT fk_trainer_employee FOREIGN KEY (trainer_id) REFERENCES worker(worker_id)
);


CREATE TABLE employee ( -- E16
	employee_id integer PRIMARY KEY,
    CONSTRAINT fk_employee FOREIGN KEY (employee_id) REFERENCES worker(worker_id)
);


CREATE TABLE contract_payment ( -- E17
	pay_doc_id bigint NOT NULL,
	contract_id bigint NOT NULL,
	CONSTRAINT fk_pay_doc_id FOREIGN KEY (pay_doc_id) REFERENCES payment_document(pay_doc_id),
	CONSTRAINT fk_contract_id FOREIGN KEY (contract_id) REFERENCES contract(contract_id)
);


CREATE TABLE worker_role ( -- E18
	worker_id integer NOT NULL,
	job_pos_id JobPosition NOT NULL,
    CONSTRAINT fk_worker_id FOREIGN KEY (worker_id) REFERENCES worker(worker_id),
	CONSTRAINT fk_job_pos_id FOREIGN KEY (job_pos_id) REFERENCES job_position(job_pos_id)
);