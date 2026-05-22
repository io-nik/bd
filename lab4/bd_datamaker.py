from faker import Faker
import random
from datetime import datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP

fake = Faker("ru_RU")
seed = 42
seed = random.randint(0, 10000)
random.seed()
Faker.seed()

# =========================
# Настройки объёма данных
# =========================
NUM_GYMS = 3
NUM_WORKERS = 18
NUM_CLIENTS = 40
NUM_CONTRACTS = 24
NUM_ABONEMENTS = NUM_CONTRACTS # = 28
NUM_EXTRA_PAYMENTS = 20
NUM_TRAININGS = 35
NUM_VISITS = 80
NUM_SERVICES = 16
NUM_TRAINING_VISITS = 50

OUTPUT_FILE = "generated_test_data.sql"


# =========================
# Справочники / enum-значения
# =========================
SEXES = ["male", "female"]

JOB_POSITIONS = [
    ("administrator", "Администратор"),
    ("accountant", "Бухгалтер"),
    ("instructor", "Инструктор"),
    ("trainer", "Тренер"),
    ("massagist", "Массажист"),
    ("nutritionist", "Нутрициолог"),
]

ABON_TYPES = ["light", "smart", "infinity"]
TRAINING_TYPES = ["personal", "group", "split"]
SERVICE_TYPES = [
    "sport_massage",
    "point_massage",
    "classic_massage",
    "spa_massage",
    "consultation",
]
TRAINING_REASONS = ["abonement", "purchase"]
TRAINER_GRADES = ["master", "expert", "top"]
CONTRACT_TYPES = ["installment", "one-time-pay"]

GYM_ZONE_NAMES = [
    ("Тренажёрный зал", "Основная зона с силовыми тренажёрами"),
    ("Кардио-зона", "Беговые дорожки, эллипсы, велотренажёры"),
    ("Зал групповых занятий", "Пространство для групповых программ"),
    ("Функциональная зона", "TRX, канаты, свободные веса"),
]

SERVICE_PRICES = {
    "sport_massage": Decimal("65.00"),
    "point_massage": Decimal("55.00"),
    "classic_massage": Decimal("50.00"),
    "spa_massage": Decimal("80.00"),
    "consultation": Decimal("40.00"),
}

ABON_PRICES = {
    "light": Decimal("90.00"),
    "smart": Decimal("120.00"),
    "infinity": Decimal("180.00"),
}


# =========================
# Вспомогательные функции
# =========================
def sql_quote(value):
    if value is None:
        return "NULL"
    if isinstance(value, str):
        return "'" + value.replace("'", "''") + "'"
    if isinstance(value, datetime):
        return "'" + value.strftime("%Y-%m-%d %H:%M:%S") + "'"
    return str(value)


def sql_date(value):
    return "'" + value.strftime("%Y-%m-%d") + "'"


def sql_timestamp(value):
    return "'" + value.strftime("%Y-%m-%d %H:%M:%S") + "'"


def make_phone():
    # В схеме: ^\+?[0-9]{11}$
    return "+7" + "".join(str(random.randint(0, 9)) for _ in range(10))


def make_passport_series():
    letters = "ABEKMHOPCTYX"
    return "".join(random.choice(letters) for _ in range(2))


def make_passport_number(existing_numbers):
    while True:
        num = str(random.randint(1000000, 9999999))
        if num not in existing_numbers:
            existing_numbers.add(num)
            return num


def random_birth_date(min_age=18, max_age=60):
    today = datetime.now().date()
    start = today - timedelta(days=max_age * 365)
    end = today - timedelta(days=min_age * 365)
    delta_days = (end - start).days
    return start + timedelta(days=random.randint(0, delta_days))


def random_hire_date(birthday, min_age_at_hire=18, max_years_after=20):
    min_date = birthday + timedelta(days=min_age_at_hire * 365 + 30)
    max_date = min(datetime.now().date(), min_date + timedelta(days=max_years_after * 365))
    if min_date >= max_date:
        return min_date + timedelta(days=1)
    delta_days = (max_date - min_date).days
    return min_date + timedelta(days=random.randint(0, delta_days))


def random_enroll_date(birthday):
    min_date = birthday + timedelta(days=18 * 365 + 30)
    max_date = datetime.now().date()
    if min_date >= max_date:
        return min_date + timedelta(days=1)
    delta_days = (max_date - min_date).days
    return min_date + timedelta(days=random.randint(0, delta_days))


def random_datetime_between(date_from, date_to, hour_from=8, hour_to=21, duration_minutes=60):
    if date_from > date_to:
        date_from, date_to = date_to, date_from
    days = (date_to - date_from).days
    base_day = date_from + timedelta(days=random.randint(0, max(days, 0)))
    start_hour = random.randint(hour_from, hour_to - 1)
    start_minute = random.choice([0, 15, 30, 45])
    dt_start = datetime(
        base_day.year, base_day.month, base_day.day, start_hour, start_minute, 0
    )
    dt_end = dt_start + timedelta(minutes=duration_minutes)
    return dt_start, dt_end


def choose_weighted_job():
    jobs = [
        "administrator",
        "accountant",
        "trainer",
        "massagist",
        "instructor",
        "nutritionist",
    ]
    weights = [3, 2, 4, 2, 2, 1]
    return random.choices(jobs, weights=weights, k=1)[0]


def abon_duration_days(abon_type):
    if abon_type == "light":
        return 30
    if abon_type == "smart":
        return 90
    return 180


def abon_duration_months(abon_type):
    if abon_type == "light":
        return 1
    if abon_type == "smart":
        return 3
    return 6


def service_specialist_role(service_type):
    if service_type == "consultation":
        return random.choice(["nutritionist", "trainer", "instructor"])
    return "massagist"


def split_payment_amount(total: Decimal, parts: int) -> list[Decimal]:
    """
    Разбивает сумму total на parts положительных частей,
    чтобы в сумме получилось ровно total.
    """
    if parts == 1:
        return [total]

    total_cents = int((total * 100).to_integral_value(rounding=ROUND_HALF_UP))

    # выбираем точки разбиения в копейках
    split_points = sorted(random.sample(range(1, total_cents), parts - 1))
    chunks = []
    prev = 0

    for point in split_points:
        chunks.append(point - prev)
        prev = point
    chunks.append(total_cents - prev)

    return [Decimal(x) / Decimal("100") for x in chunks]


def random_partial_total(total: Decimal) -> Decimal:
    """
    Возвращает сумму, которая меньше total, но не слишком маленькая.
    Например, 40%-90% от полной суммы.
    """
    min_ratio = Decimal("0.40")
    max_ratio = Decimal("0.90")

    ratio = Decimal(str(random.uniform(float(min_ratio), float(max_ratio))))
    partial = (total * ratio).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    # защита от случайного равенства total
    if partial >= total:
        partial = (total - Decimal("0.01")).quantize(Decimal("0.01"))

    # защита от слишком маленькой суммы
    if partial <= Decimal("0.00"):
        partial = Decimal("0.01")

    return partial


# =========================
# Генерация данных
# =========================
statements = []
passport_numbers = set()

# Очистка таблиц в правильном порядке
statements.extend([
    "-- =========================",
    "-- Случайные тестовые данные",
    "-- =========================",
    "",
    "TRUNCATE TABLE "
    "worker_role, contract_payment, employee, trainer, training_visit, "
    "employee_place_of_work, service, visit, training, gym_zone, "
    "payment_document, payment_plan, contract, abonement, client, worker, gym, job_position "
    "RESTART IDENTITY CASCADE;",
    ""
])

# job_position
statements.append("-- Должности")
for job_id, job_name in JOB_POSITIONS:
    statements.append(
        f"INSERT INTO job_position (job_pos_id, job_pos_name) VALUES "
        f"({sql_quote(job_id)}, {sql_quote(job_name)});"
    )
statements.append("")

# gym
gyms = []
statements.append("-- Залы")
for i in range(1, NUM_GYMS + 1):
    gym = {
        "gym_id": i,
        "gym_name": f"Fitness Club #{i}",
        "address": f"г. Минск, ул. Спортивная, {10 + i}",
        "phone_num": make_phone(),
    }
    gyms.append(gym)
    statements.append(
        "INSERT INTO gym (gym_name, address, phone_num) VALUES "
        f"({sql_quote(gym['gym_name'])}, {sql_quote(gym['address'])}, {sql_quote(gym['phone_num'])});"
    )
statements.append("")

# gym_zone
zones = []
statements.append("-- Зоны в залах")
for gym in gyms:
    zone_count = random.randint(2, 4)
    chosen_zone_defs = random.sample(GYM_ZONE_NAMES, zone_count)
    for zone_idx, (zone_name, description) in enumerate(chosen_zone_defs, start=1):
        zone = {
            "gym_id": gym["gym_id"],
            "zone_id": zone_idx,
            "zone_name": zone_name,
            "description": description,
        }
        zones.append(zone)
        statements.append(
            "INSERT INTO gym_zone (zone_id, gym_id, zone_name, description) VALUES "
            f"({zone['zone_id']}, {gym['gym_id']}, {sql_quote(zone_name)}, {sql_quote(description)});"
        )
statements.append("")

# worker
workers = []
worker_roles = []
trainers = []
employees = []
employee_places = []

admin_worker_ids = []
accountant_worker_ids = []
trainer_worker_ids = []
massagist_worker_ids = []
nutritionist_worker_ids = []
instructor_worker_ids = []

statements.append("-- Сотрудники")
for worker_id in range(1, NUM_WORKERS + 1):
    sex = random.choice(SEXES)
    full_name = fake.name_male() if sex == "male" else fake.name_female()
    birthday = random_birth_date(20, 55)
    hire_date = random_hire_date(birthday, min_age_at_hire=18, max_years_after=18)
    experience_max = max(1, int((hire_date - birthday).days / 365) - 18)
    experience = random.randint(0, min(experience_max, 20))

    worker = {
        "worker_id": worker_id,
        "full_name": full_name,
        "passport_series": make_passport_series(),
        "passport_number": make_passport_number(passport_numbers),
        "sex": sex,
        "experience": experience,
        "birthday": birthday,
        "hire_date": hire_date,
    }
    workers.append(worker)

    statements.append(
        "INSERT INTO worker "
        "(full_name, passport_series, passport_number, sex, experience, birthday, hire_date) VALUES "
        f"({sql_quote(worker['full_name'])}, "
        f"{sql_quote(worker['passport_series'])}, "
        f"{sql_quote(worker['passport_number'])}, "
        f"{sql_quote(worker['sex'])}, "
        f"{worker['experience']}, "
        f"{sql_timestamp(datetime.combine(worker['birthday'], datetime.min.time()))}, "
        f"{sql_date(worker['hire_date'])});"
    )

    job = choose_weighted_job()
    worker_roles.append((worker_id, job))
    employees.append(worker_id)

    work_gym = random.choice(gyms)
    employee_places.append((worker_id, work_gym["gym_id"]))

    if job == "administrator":
        admin_worker_ids.append(worker_id)
    elif job == "accountant":
        accountant_worker_ids.append(worker_id)
    elif job == "trainer":
        trainer_worker_ids.append(worker_id)
        trainers.append((worker_id, random.choice(TRAINER_GRADES)))
    elif job == "massagist":
        massagist_worker_ids.append(worker_id)
    elif job == "nutritionist":
        nutritionist_worker_ids.append(worker_id)
    elif job == "instructor":
        instructor_worker_ids.append(worker_id)

# гарантируем наличие нужных ролей
def ensure_role(target_list, role_name):
    if target_list:
        return
    candidate = random.randint(1, NUM_WORKERS)
    worker_roles[candidate - 1] = (candidate, role_name)
    if role_name == "administrator":
        admin_worker_ids.append(candidate)
    elif role_name == "accountant":
        accountant_worker_ids.append(candidate)
    elif role_name == "trainer":
        trainer_worker_ids.append(candidate)
        trainers.append((candidate, random.choice(TRAINER_GRADES)))
    elif role_name == "massagist":
        massagist_worker_ids.append(candidate)

ensure_role(admin_worker_ids, "administrator")
ensure_role(accountant_worker_ids, "accountant")
ensure_role(trainer_worker_ids, "trainer")
ensure_role(massagist_worker_ids, "massagist")

statements.append("")
statements.append("-- Роли сотрудников")
for worker_id, job in worker_roles:
    statements.append(
        "INSERT INTO worker_role (worker_id, job_pos_id) VALUES "
        f"({worker_id}, {sql_quote(job)});"
    )
statements.append("")

statements.append("-- Все работники, кроме trainers, считаются employee")
for employee_id in employees:
    if employee_id not in trainer_worker_ids:
        statements.append(
            f"INSERT INTO employee (employee_id) VALUES ({employee_id});"
        )
statements.append("")

statements.append("-- Тренеры")
trainer_ids_unique = sorted(set(t[0] for t in trainers))
for trainer_id in trainer_ids_unique:
    grade = random.choice(TRAINER_GRADES)
    statements.append(
        "INSERT INTO trainer (trainer_id, grade) VALUES "
        f"({trainer_id}, {sql_quote(grade)});"
    )
statements.append("")

statements.append("-- Место работы сотрудников")
for worker_id, gym_id in employee_places:
    statements.append(
        "INSERT INTO employee_place_of_work (worker_id, gym_id) VALUES "
        f"({worker_id}, {gym_id});"
    )
statements.append("")

# client
clients = []
statements.append("-- Клиенты")
for client_id in range(1, NUM_CLIENTS + 1):
    sex = random.choice(SEXES)
    full_name = fake.name_male() if sex == "male" else fake.name_female()
    birthday = random_birth_date(18, 60)
    enroll_date = random_enroll_date(birthday)

    client = {
        "client_id": client_id,
        "full_name": full_name,
        "passport_series": make_passport_series(),
        "passport_number": make_passport_number(passport_numbers),
        "sex": sex,
        "phone_num": make_phone(),
        "birthday": birthday,
        "enroll_date": enroll_date,
    }
    clients.append(client)

    statements.append(
        "INSERT INTO client "
        "(full_name, passport_series, passport_number, sex, phone_num, birthday, enroll_date) VALUES "
        f"({sql_quote(client['full_name'])}, "
        f"{sql_quote(client['passport_series'])}, "
        f"{sql_quote(client['passport_number'])}, "
        f"{sql_quote(client['sex'])}, "
        f"{sql_quote(client['phone_num'])}, "
        f"{sql_timestamp(datetime.combine(client['birthday'], datetime.min.time()))}, "
        f"{sql_date(client['enroll_date'])});"
    )
statements.append("")


contracts = []
payment_documents = []
contract_payments = []
payment_plans = []

for contract_id in range(1, NUM_CONTRACTS + 1):
    client = random.choice(clients)
    admin_id = random.choice(admin_worker_ids)
    accountant_id = random.choice(accountant_worker_ids)

    # 1. Уникальный абонемент
    abon_type = random.choice(ABON_TYPES)
    duration_days = abon_duration_days(abon_type)
    duration_month = abon_duration_months(abon_type)

    start_min = max(client["enroll_date"], datetime.now().date() - timedelta(days=365))
    start_max = datetime.now().date() + timedelta(days=30)
    delta_days = max((start_max - start_min).days, 1)

    date_start = start_min + timedelta(days=random.randint(0, delta_days))
    time_start = datetime(date_start.year, date_start.month, date_start.day, 0, 0, 0)
    time_end = time_start + timedelta(days=duration_days, hours=23, minutes=59, seconds=59)

    statements.append(
        "INSERT INTO abonement (abon_type, date_start, date_end) VALUES "
        f"({sql_quote(abon_type)}, {sql_timestamp(time_start)}, {sql_timestamp(time_end)});"
    )

    abon_id = contract_id

    # 2. Договор
    sign_date = time_start - timedelta(
        days=random.randint(0, 7),
        hours=random.randint(0, 8),
        minutes=random.choice([0, 15, 30, 45]),
    )

    summ = ABON_PRICES[abon_type]

    # тип договора
    contract_type = random.choices(
        ["one-time-pay", "installment"],
        weights=[60, 40],
        k=1
    )[0]

    if duration_month < 2:
        contract_type = "one-time-pay"

    installment_month = None
    if contract_type == "installment":
        # количество платежей в рассрочке
        installment_month = random.randint(2, duration_month)

    contract = {
        "contract_id": contract_id,
        "client_id": client["client_id"],
        "admin_employee_id": admin_id,
        "summ": summ,
        "duration_month": duration_month,
        "contract_type": contract_type,
        "installment_month": installment_month,
        "abon_id": abon_id,
        "date_sign": sign_date,
    }
    contracts.append(contract)

    statements.append(
        "INSERT INTO contract "
        "(client_id, admin_employee_id, summ, duration_month, contract_type, installment_month, abon_id, date_sign) VALUES "
        f"({contract['client_id']}, {contract['admin_employee_id']}, {contract['summ']}, "
        f"{contract['duration_month']}, {sql_quote(contract['contract_type'])}, "
        f"{'NULL' if contract['installment_month'] is None else contract['installment_month']}, "
        f"{contract['abon_id']}, {sql_timestamp(contract['date_sign'])});"
    )

    # 3. Платёжки и payment_plan
    if contract_type == "one-time-pay":
        num_payments = 1
    else:
        num_payments = installment_month

    is_partial_payment = False
    if num_payments > 1:
        is_partial_payment = random.choices(
            [True, False],
            weights=[30, 70],
            k=1
        )[0]

    if is_partial_payment:
        paid_total = random_partial_total(summ)
    else:
        paid_total = summ

    payment_parts = split_payment_amount(paid_total, num_payments)
    planned_parts = split_payment_amount(summ, num_payments)

    payment_date = sign_date + timedelta(minutes=random.randint(5, 90))

    created_pay_doc_ids = []

    for payment_num in range(1, num_payments + 1):
        planned_amount = planned_parts[payment_num - 1]

        # для реально существующих платёжек
        if payment_num <= len(payment_parts):
            actual_amount = payment_parts[payment_num - 1]

            pay_doc_id = len(payment_documents) + 1
            account_number = f"ACC-{pay_doc_id:05d}"

            pay_doc = {
                "pay_doc_id": pay_doc_id,
                "account_number": account_number,
                "summ": actual_amount,
                "description": f"Оплата абонемента {abon_type} по договору #{contract_id}",
                "accountant_employee_id": accountant_id,
                "date_sign": payment_date,
                "client_id": client["client_id"],
            }
            payment_documents.append(pay_doc)
            created_pay_doc_ids.append(pay_doc_id)

            statements.append(
                "INSERT INTO payment_document "
                "(account_number, summ, description, accountant_employee_id, date_sign, client_id) VALUES "
                f"({sql_quote(pay_doc['account_number'])}, {pay_doc['summ']}, "
                f"{sql_quote(pay_doc['description'])}, {pay_doc['accountant_employee_id']}, "
                f"{sql_timestamp(pay_doc['date_sign'])}, {pay_doc['client_id']});"
            )

            statements.append(
                f"INSERT INTO contract_payment (pay_doc_id, contract_id) VALUES ({pay_doc_id}, {contract_id});"
            )

            statements.append(
                "INSERT INTO payment_plan "
                "(contract_id, payment_num, due_date, planned_amount, is_paid, pay_doc_id) VALUES "
                f"({contract_id}, {payment_num}, "
                f"{sql_timestamp(payment_date + timedelta(days=30))}, "
                f"{planned_amount}, true, {pay_doc_id});"
            )

            payment_date = payment_date + timedelta(days=random.randint(25, 35))

        else:
            # запланированный, но ещё не оплаченный платёж
            due_date = sign_date + timedelta(days=30 * payment_num)

            statements.append(
                "INSERT INTO payment_plan "
                "(contract_id, payment_num, due_date, planned_amount, is_paid, pay_doc_id) VALUES "
                f"({contract_id}, {payment_num}, "
                f"{sql_timestamp(due_date)}, {planned_amount}, false, NULL);"
            )

# дополнительные платежи
statements.append("-- Дополнительные платежные документы")
for _ in range(NUM_EXTRA_PAYMENTS):
    pay_doc_id = len(payment_documents) + 1
    client = random.choice(clients)
    accountant_id = random.choice(accountant_worker_ids)
    amount = Decimal(str(random.choice([35, 40, 45, 50, 55, 60, 70, 80])))
    pay_time_start = datetime.now().date() - timedelta(days=120)
    pay_time_end = datetime.now().date() + timedelta(days=10)
    dt_start, _ = random_datetime_between(pay_time_start, pay_time_end, 9, 20, 30)

    pay_doc = {
        "pay_doc_id": pay_doc_id,
        "account_number": f"ACC-{pay_doc_id:05d}",
        "summ": amount,
        "description": random.choice([
            "Разовая оплата услуги",
            "Оплата консультации",
            "Оплата массажа",
            "Оплата персональной тренировки",
        ]),
        "accountant_employee_id": accountant_id,
        "date_sign": dt_start,
        "client_id": client["client_id"],
    }
    payment_documents.append(pay_doc)

    statements.append(
        "INSERT INTO payment_document "
        "(account_number, summ, description, accountant_employee_id, date_sign, client_id) VALUES "
        f"({sql_quote(pay_doc['account_number'])}, {pay_doc['summ']}, "
        f"{sql_quote(pay_doc['description'])}, {pay_doc['accountant_employee_id']}, "
        f"{sql_timestamp(pay_doc['date_sign'])}, {pay_doc['client_id']});"
    )
statements.append("")

# training
trainings = []
statements.append("-- Тренировки")
for training_id in range(1, NUM_TRAININGS + 1):
    trainer_id = random.choice(trainer_worker_ids)
    zone = random.choice(zones)
    date_from = datetime.now().date() - timedelta(days=90)
    date_to = datetime.now().date() + timedelta(days=20)
    duration = random.choice([45, 60, 75, 90])
    time_start, time_end = random_datetime_between(date_from, date_to, 8, 21, duration)

    training = {
        "training_id": training_id,
        "trainer_id": trainer_id,
        "zone_id": zone["zone_id"],
        "gym_id": zone["gym_id"],
        "time_start": time_start,
        "time_end": time_end,
        "training_type": random.choice(TRAINING_TYPES),
    }
    trainings.append(training)

    statements.append(
        "INSERT INTO training "
        "(trainer_id, zone_id, gym_id, time_start, time_end, training_type) VALUES "
        f"({trainer_id}, {zone['zone_id']}, {zone['gym_id']}, "
        f"{sql_timestamp(time_start)}, {sql_timestamp(time_end)}, "
        f"{sql_quote(training['training_type'])});"
    )
statements.append("")

# visit
statements.append("-- Посещения")
for _ in range(NUM_VISITS):
    client = random.choice(clients)
    gym = random.choice(gyms)
    date_from = datetime.now().date() - timedelta(days=120)
    date_to = datetime.now().date() + timedelta(days=10)
    enter_time, _ = random_datetime_between(date_from, date_to, 6, 21, 60)
    exit_time = enter_time + timedelta(minutes=random.choice([45, 60, 75, 90, 120]))

    statements.append(
        "INSERT INTO visit (client_id, gym_id, time_enter, time_exit) VALUES "
        f"({client['client_id']}, {gym['gym_id']}, "
        f"{sql_timestamp(enter_time)}, {sql_timestamp(exit_time)});"
    )
statements.append("")

# service
services = []
available_paid_docs = payment_documents[:]

statements.append("-- Услуги")
for service_id in range(1, NUM_SERVICES + 1):
    service_type = random.choice(SERVICE_TYPES)
    required_role = service_specialist_role(service_type)

    if required_role == "massagist" and massagist_worker_ids:
        specialist_id = random.choice(massagist_worker_ids)
    elif required_role == "nutritionist" and nutritionist_worker_ids:
        specialist_id = random.choice(nutritionist_worker_ids)
    elif required_role == "trainer" and trainer_worker_ids:
        specialist_id = random.choice(trainer_worker_ids)
    elif instructor_worker_ids:
        specialist_id = random.choice(instructor_worker_ids)
    else:
        specialist_id = random.choice(workers)["worker_id"]

    pay_doc = random.choice(available_paid_docs)
    service_client_id = pay_doc["client_id"]

    start_time = pay_doc["date_sign"] + timedelta(minutes=random.choice([15, 30, 60, 120]))
    end_time = start_time + timedelta(minutes=random.choice([30, 45, 60, 75]))

    service = {
        "service_id": service_id,
        "service_type": service_type,
        "description": {
            "sport_massage": "Спортивный массаж",
            "point_massage": "Точечный массаж",
            "classic_massage": "Классический массаж",
            "spa_massage": "SPA-массаж",
            "consultation": "Консультация специалиста",
        }[service_type],
        "pay_doc_id": pay_doc["pay_doc_id"],
        "client_id": service_client_id,
        "specialist_id": specialist_id,
        "time_start": start_time,
        "time_end": end_time,
    }
    services.append(service)

    statements.append(
        "INSERT INTO service "
        "(service_type, description, pay_doc_id, client_id, specialist_id, time_start, time_end) VALUES "
        f"({sql_quote(service['service_type'])}, {sql_quote(service['description'])}, "
        f"{service['pay_doc_id']}, {service['client_id']}, {service['specialist_id']}, "
        f"{sql_timestamp(service['time_start'])}, {sql_timestamp(service['time_end'])});"
    )
statements.append("")

# training_visit
statements.append("-- Посещения тренировок")
for _ in range(NUM_TRAINING_VISITS):
    client = random.choice(clients)
    training = random.choice(trainings)
    reason = random.choice(TRAINING_REASONS)

    contract_id = None
    pay_doc_id = None

    if reason == "abonement" and contracts:
        same_client_contracts = [c for c in contracts if c["client_id"] == client["client_id"]]
        if same_client_contracts:
            contract_id = random.choice(same_client_contracts)["contract_id"]
        else:
            reason = "purchase"

    if reason == "purchase":
        same_client_docs = [
            d for d in payment_documents
            if d["client_id"] == client["client_id"]
               and d["description"] == "Оплата персональной тренировки"
        ]
        if same_client_docs:
            pay_doc_id = random.choice(same_client_docs)["pay_doc_id"]
        elif contracts:
            same_client_contracts = [c for c in contracts if c["client_id"] == client["client_id"]]
            if same_client_contracts:
                reason = "abonement"
                contract_id = random.choice(same_client_contracts)["contract_id"]

    statements.append(
        "INSERT INTO training_visit (client_id, training_id, training_reason, contract_id, pay_doc_id) VALUES "
        f"({client['client_id']}, {training['training_id']}, {sql_quote(reason)}, "
        f"{'NULL' if contract_id is None else contract_id}, "
        f"{'NULL' if pay_doc_id is None else pay_doc_id});"
    )
statements.append("")

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write("\n".join(statements))

print(f"Готово. SQL сохранён в файл: {OUTPUT_FILE}")