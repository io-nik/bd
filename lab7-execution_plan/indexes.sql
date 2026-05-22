-- 5
CREATE INDEX idx_visit_time_client -- составной индекс
ON visit (time_enter, client_id);

CREATE INDEX idx_pay_doc_date_client_include_sum -- покрывающий
ON payment_document (date_sign, client_id)
INCLUDE (summ);

-- 4
CREATE INDEX idx_training_visit_purchase -- частичный
ON training_visit (training_id, pay_doc_id)
WHERE training_reason = 'purchase';

ANALYZE;

-- доп
-- 5
CREATE INDEX idx_service_time_client
ON service (time_start, client_id);

CREATE INDEX idx_training_time_id
ON training (time_start, training_id);

CREATE INDEX idx_training_visit_training_client
ON training_visit (training_id, client_id);

-- 4
CREATE INDEX idx_training_personal_group
ON training (training_id, training_type)
WHERE training_type IN ('personal', 'group');

CREATE INDEX idx_pay_doc_id_include_sum
ON payment_document (pay_doc_id)
INCLUDE (summ);

CREATE INDEX idx_service_pay_doc
ON service (pay_doc_id);