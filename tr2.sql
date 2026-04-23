CREATE OR REPLACE FUNCTION training_members_count()
RETURNS TRIGGER AS $$
DECLARE
	train_type TrainingType;
	max_count integer;
	curr_count integer;
BEGIN
	SELECT t2.training_type INTO train_type 
    FROM training t2
    WHERE t2.training_id = NEW.training_id;

	CASE
		WHEN train_type = 'personal' THEN max_count := 1;
		WHEN train_type = 'split' THEN max_count := 3;
		WHEN train_type = 'group' THEN max_count := 10;
	END CASE;

	SELECT COUNT(*) INTO curr_count
    FROM training_visit tv
    WHERE tv.training_id = NEW.training_id;

	IF curr_count >= max_count THEN RAISE EXCEPTION 'There are no available places!';
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_training_members_count_control
BEFORE INSERT 
ON training_visit
FOR EACH ROW
EXECUTE FUNCTION training_members_count();

