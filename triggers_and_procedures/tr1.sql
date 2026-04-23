CREATE OR REPLACE FUNCTION pay_plan_create()
RETURNS TRIGGER AS $$
DECLARE
	surcharge numeric(8,2);
	total numeric(8,2);
	month_pay numeric(8,2);
BEGIN
	
	IF NEW.contract_type = 'installment' AND 
			NEW.installment_month IS NOT NULL AND NEW.installment_month > 1 THEN
		IF NEW.installment_month < 6 THEN
			surcharge := 0.10;
		ELSE
			surcharge := 0.15;
		END IF;
		total := NEW.summ * (1 + surcharge);
		month_pay := ROUND(total / NEW.installment_month, 2);
		FOR i IN 1..NEW.installment_month LOOP
			INSERT INTO payment_plan(contract_id, payment_num, due_date, 
					planned_amount) VALUES
			(NEW.contract_id, i, now() + (i * INTERVAL '1 month'), month_pay);
		END LOOP;
	END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trig_pay_plan_create
AFTER INSERT
ON contract
FOR EACH ROW
EXECUTE FUNCTION pay_plan_create();

