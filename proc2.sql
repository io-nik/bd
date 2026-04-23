CREATE OR REPLACE PROCEDURE move_personal_train(_trainer_id integer, _client_id int, 
old_time_start timestamp, old_time_end timestamp,
_time_start timestamp, _time_end timestamp)
LANGUAGE plpgsql
AS $$
DECLARE
	train_id bigint;
BEGIN -- проверка доступности тренера и отсутствия у клиента 
-- других тренировок в новом временном интервале
	IF _time_start >= _time_end THEN
		RAISE EXCEPTION 'Error! Incorrect time interval!';
	END IF;
	IF old_time_start >= old_time_end THEN
		RAISE EXCEPTION 'Error! Incorrect time interval!';
	END IF;
	IF NOT EXISTS (
		SELECT 1
		FROM trainer t
		WHERE t.trainer_id = _trainer_id
	) THEN
		RAISE EXCEPTION 'Error! This worker is not a trainer!';
	END IF;

	SELECT tr.training_id INTO train_id -- find old training
	FROM training tr
	JOIN training_visit tv ON tv.training_id = tr.training_id
	WHERE tr.trainer_id = _trainer_id AND tv.client_id = _client_id AND
		tr.training_type = 'personal' AND tr.time_start = old_time_start AND
		tr.time_end = old_time_end;
	IF train_id IS NULL THEN
		RAISE EXCEPTION 'Error! Personal training not found!';
	END IF;
	
	IF EXISTS (
		SELECT 1 
		FROM training tr1
		WHERE tr1.trainer_id = _trainer_id AND 
			tr1.time_start < _time_end AND tr1.time_end > _time_start
			AND tr1.training_id <> train_id
	) THEN 
		RAISE EXCEPTION 'Error! The trainer is busy at this time!';
	END IF;

	IF EXISTS (
		SELECT 1 
		FROM training_visit tv
		JOIN training tr ON tv.training_id = tr.training_id
		WHERE tv.client_id = _client_id AND 
			tr.time_start < _time_end AND tr.time_end > _time_start
			AND tr.training_id <> train_id
	) THEN 
		RAISE EXCEPTION 'Error! The client is busy at this time!';
	END IF;

	UPDATE training
	SET time_start = _time_start, time_end = _time_end
	WHERE training_id = train_id;
END;
$$;