/*
	Куликов Леонид
	6103
	Вариант 2
*/

/* Л.Р. №1. Создание и заполнение отношений БД поликлиники. */

/* --1. Отношение "Врачи" (поля "ФИО врача", "Должность", "Специализация", "Кабинет"). */
drop table doc;
CREATE TABLE doc (
	id INTEGER NOT NULL PRIMARY KEY,
	name VARCHAR(60) NOT NULL,
	post VARCHAR(40) NOT NULL,
	spec VARCHAR(60) NOT NULL,
	cab_num VARCHAR(10) NOT NULL
);

INSERT INTO doc (id, name, post, spec, cab_num)
VALUES (0, 'Пупкин Василий Пупкинович', 'Хирург', 'Конечности', '14');
INSERT INTO doc (id, name, post, spec, cab_num)
VALUES (1, 'Папалардо Арина Генадьевна', 'Хирург', 'Конечности', '16');
INSERT INTO doc (id, name, post, spec, cab_num)
VALUES (2, 'Дронова Зинаида Васильевна', 'Терапевт', 'ОРВИ', '15');
INSERT INTO doc (id, name, post, spec, cab_num)
VALUES (3, 'Петров Иван Генадьевич', 'Окулист', 'Яблоко', '9');
INSERT INTO doc (id, name, post, spec, cab_num)
VALUES (4, 'Фокин Мартын Ильяович', 'Дерматолог', 'Общая', '30');
INSERT INTO doc (id, name, post, spec, cab_num)
VALUES (5, 'Морозов Моисей Мэлсович', 'Радиолог', 'Конечности', '31');
INSERT INTO doc (id, name, post, spec, cab_num)
VALUES (6, 'Горшков Юстиниан Николаевич', 'Стоматолог', 'Общая', '32');
INSERT INTO doc (id, name, post, spec, cab_num)
VALUES (7, 'Суханов Карл Федотович', 'Эндокринолог', 'Общая', '33');

/*
	--2. Отношение "Пациенты":
	Содержимое поля		Тип		Длина	Дес.	Примечание
	Регистрационный №	N		6		0		первичный ключ
	ФИО					C		40				обязательное поле
	Пол					C		1				значения – 'м' и 'ж', по умолчанию – 'м'
	Дата рождения		D						обязательное поле
	Номер полиса		C		16				обязательное поле
	Адрес				C		40				обязательное поле
	Телефон				C		11
*/
drop table pat;
CREATE TABLE pat (
	id INTEGER NOT NULL PRIMARY KEY,
	name VARCHAR(60) NOT NULL,
	sex CHAR(1) DEFAULT 'm' CHECK (sex = 'm' OR sex = 'f'),
	birth_date DATE NOT NULL,
	polis_num CHAR(16) NOT NULL,
	address VARCHAR(40) NOT NULL,
	phone CHAR(11)
);

CREATE TABLE pats_archive (
	id INTEGER NOT NULL PRIMARY KEY,
	name VARCHAR(60) NOT NULL,
	sex CHAR(1) DEFAULT 'm' CHECK (sex = 'm' OR sex = 'f'),
	birth_date DATE NOT NULL,
	polis_num CHAR(16) NOT NULL,
	address VARCHAR(40) NOT NULL,
	phone CHAR(11)
);

INSERT INTO pat (id, name, sex, birth_date, polis_num, address, phone)
VALUES (1, 'Кононов Орест Лаврентьевич', 'm', sysdate, '1151284745874516', 'Генерала Жданова 16, 62', '79011238943');
INSERT INTO pat (id, name, sex, birth_date, polis_num, address, phone)
VALUES (2, 'Колесников Бенедикт Альвианович', 'f', TO_DATE('20191009','YYYYMMDD'), '3611191889974144', 'Робеспьера 22, 24', '79111238943');
INSERT INTO pat (id, name, sex, birth_date, polis_num, address, phone)
VALUES (3, 'Калашников Витольд Германович', 'f', sysdate, '1895928323331236', 'Авиаторов 30, 97', '78111238943');
INSERT INTO pat (id, name, sex, birth_date, polis_num, address, phone)
VALUES (4, 'Богданова Гертруда Парфеньевна', 'm', TO_DATE('20181009','YYYYMMDD'), '2256522568374859', 'Генерала Жданова 13, 90', NULL);
INSERT INTO pat (id, name, sex, birth_date, polis_num, address, phone)
VALUES (5, 'Белова Владлена Ивановна', 'm', TO_DATE('20171109','YYYYMMDD'), '9538441293924474', 'Гагарина 25, 52', NULL);
INSERT INTO pat (id, name, sex, birth_date, polis_num, address, phone)
VALUES (6, 'Фомичёва Романа Робертовна', 'f', TO_DATE('20161209','YYYYMMDD'), '6321919287215462', 'Болотная 29, 60', '78111238953');

/* --3. Отношение "Визиты к врачу" (поля "Врач", "Пациент", "Дата и время визита", "Диагноз"). */
drop table visit_to_doc;
CREATE TABLE visit_to_doc (
	id INTEGER NOT NULL PRIMARY KEY,
	doctor INT NOT NULL REFERENCES doc (id),
	patient INT DEFAULT NULL REFERENCES pat (id),
	visit_time TIMESTAMP NOT NULL,
	end_visit_time TIMESTAMP NOT NULL,
	diagnosis VARCHAR(100)
);

INSERT INTO visit_to_doc (id, doctor, patient, visit_time, end_visit_time, diagnosis)
VALUES (1, 1, 1, TO_TIMESTAMP('01/05/2018 11:58:00', 'MM/DD/YYYY HH24:MI:SS'), sysdate, 'Laziness');
INSERT INTO visit_to_doc (id, doctor, patient, visit_time, end_visit_time, diagnosis)
VALUES (2, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + 1/24, 'Parkinson');
INSERT INTO visit_to_doc (id, doctor, patient, visit_time, end_visit_time, diagnosis)
VALUES (3, 2, 2, TO_TIMESTAMP('04/10/2017 10:59:00', 'MM/DD/YYYY HH24:MI:SS'), sysdate, 'Parkinson');
INSERT INTO visit_to_doc (id, doctor, patient, visit_time, end_visit_time, diagnosis)
VALUES (4, 1, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + 1/24, 'Osteochondrosis');
INSERT INTO visit_to_doc (id, doctor, patient, visit_time, end_visit_time, diagnosis)
VALUES (5, 3, 5, TO_TIMESTAMP('02/08/2017 09:44:00', 'MM/DD/YYYY HH24:MI:SS'), sysdate, 'Parkinson');
INSERT INTO visit_to_doc (id, doctor, patient, visit_time, end_visit_time, diagnosis)
VALUES (6, 4, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + 1/24, 'Osteochondrosis');

/* --4. 4. Отношение "Назначения" (поля "Визит", "Назначение"). */
drop table appoint;
CREATE TABLE appoint (
	visit INTEGER NOT NULL REFERENCES visit_to_doc (id),
	dest VARCHAR(100) NOT NULL
);

INSERT INTO appoint (visit, dest)
VALUES (3, 'Назначение 1');
INSERT INTO appoint (visit, dest)
VALUES (1, 'Назначение 2');
INSERT INTO appoint (visit, dest)
VALUES (2, 'Назначение 3');
INSERT INTO appoint (visit, dest)
VALUES (4, 'Назначение 4');
INSERT INTO appoint (visit, dest)
VALUES (5, 'Назначение 5');
INSERT INTO appoint (visit, dest)
VALUES (5, 'Назначение 6');


create or replace procedure current_schedule is
    cursor popular_doctors(cur_date date) is
        select doctor, COUNT(*) as visit_count
        from DOC join VISIT_TO_DOC on DOC.ID = VISIT_TO_DOC.DOCTOR
        where trunc(VISIT_TO_DOC.VISIT_TIME) = cur_date
        group by doctor
        order by visit_count desc;

    cursor visits(doctor integer, cur_date date) is
        select v.VISIT_TIME, v.PATIENT, p.ADDRESS
        from VISIT_TO_DOC v join PAT p on v.PATIENT = p.ID
        where v.DOCTOR = doctor
        order by v.VISIT_TIME;
begin
    for popular_doctor in popular_doctors(sysdate)
        loop
            DBMS_OUTPUT.PUT_LINE(SHORTEN_NAME(popular_doctor.DOCTOR));
            for v in visits(popular_doctor.DOCTOR, sysdate)
                loop
                    DBMS_OUTPUT.PUT_LINE(v.VISIT_TIME || ', '
                                             || SHORTEN_NAME(v.PATIENT) || ', '
                                             || v.ADDRESS);
                end loop;

        end loop;
end;

begin
    current_schedule();
end;