CREATE OR REPLACE PROCEDURE create_group_train(_trainer_id integer, _gym_id int, 
	_zone_id smallint, _time_start timestamp, _time_end timestamp, 
	client_ids integer[], reasons TrainingReason[])
LANGUAGE plpgsql
AS $$
DECLARE
	max_count integer;
	curr_count integer;
	train_id bigint;
BEGIN -- Перед созданием записи процедура должна проверить доступность 
-- инструктора и зоны на заданное время, а также убедиться, что количество участников
-- не превышает допустимый лимит
	IF cardinality(client_ids) != cardinality(reasons) THEN
		RAISE EXCEPTION 'Error! Do not have enough clients/reasons!';
	END IF;
	IF _time_start >= _time_end THEN
		RAISE EXCEPTION 'Error! Incorrect time interval!';
	END IF;
	IF NOT EXISTS (
		SELECT 1
		FROM trainer t
		WHERE t.trainer_id = _trainer_id
	) THEN
		RAISE EXCEPTION 'Error! This worker is not a trainer!';
	END IF;

	IF EXISTS (
		SELECT 1 
		FROM training tr1
		WHERE tr1.trainer_id = _trainer_id AND 
			tr1.time_start < _time_end AND tr1.time_end > _time_start
	) THEN 
		RAISE EXCEPTION 'Error! The trainer is busy at this time!';
	END IF;

	IF EXISTS (
		SELECT 1 
		FROM training tr2
		WHERE tr2.gym_id = _gym_id AND tr2.zone_id = _zone_id AND
			tr2.time_start < _time_end AND tr2.time_end > _time_start
	) THEN 
		RAISE EXCEPTION 'Error! The zone is busy at this time!';
	END IF;

	curr_count := cardinality(client_ids);
	max_count := 10;
	IF curr_count > max_count THEN
		RAISE EXCEPTION 'Error! There are too many participants!';
	END IF;

	INSERT INTO training(trainer_id, zone_id, gym_id, time_start, time_end, training_type)
	VALUES (_trainer_id, _zone_id, _gym_id, _time_start, _time_end, 'group')
	RETURNING training_id INTO train_id;

	FOR i IN 1..curr_count LOOP
		INSERT INTO training_visit(client_id, training_id, training_reason) VALUES
		(client_ids[i], train_id, reasons[i]);
	END LOOP;
END;
$$;
