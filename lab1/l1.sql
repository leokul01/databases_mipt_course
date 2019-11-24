/* 	
	Куликов Леонид
	6103
	Вариант 2
*/

/* Л.Р. №1. Создание и заполнение отношений БД поликлиники. */

/* --1. Отношение "Врачи" (поля "ФИО врача", "Должность", "Специализация", "Кабинет"). */
CREATE TABLE doc (
	id SERIAL PRIMARY KEY,
	name VARCHAR(40) NOT NULL,
	post VARCHAR(40) NOT NULL,
	spec VARCHAR(60) NOT NULL,
	cab_num VARCHAR(10) NOT NULL
);

INSERT INTO doc (name, post, spec, cab_num)
VALUES 	('Пупкин Василий Пупкинович', 'Хирург', 'Конечности', '14'),
		('Папалардо Арина Генадьевна', 'Хирург', 'Конечности', '16'),
		('Дронова Зинаида Васильевна', 'Терапевт', 'ОРВИ', '15'),
		('Петров Иван Генадьевич', 'Окулист', 'Яблоко', '9');

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
CREATE TABLE pat (
	id SERIAL PRIMARY KEY,
	name VARCHAR(40) NOT NULL,
	sex CHAR(1) DEFAULT 'm' CHECK (sex = 'm' OR sex = 'f'),
	birth_date DATE NOT NULL,
	polis_num CHAR(16) NOT NULL,
	address VARCHAR(40) NOT NULL,
	phone CHAR(11)
);

INSERT INTO pat (name, sex, birth_date, polis_num, address, phone)
VALUES 	('Пациент 1', 'm', NOW(), '1234567890123456', 'AWESOME ADDRESS', '79011238943'),
		('Пациент 2', 'f', TO_DATE('20191009','YYYYMMDD'), '2134567890123456', 'GOOD ADDRESS', '79111238943'),
		('Пациент 3', 'f', CURRENT_DATE, '3214567890123456', 'NICE ADDRESS', '78111238943');

/* --3. Отношение "Визиты к врачу" (поля "Врач", "Пациент", "Дата и время визита", "Диагноз"). */
CREATE TABLE visit_to_doc (
	id SERIAL PRIMARY KEY,
	doctor INT NOT NULL REFERENCES doc (id),
	patient INT NOT NULL REFERENCES pat (id),
	visit_time TIMESTAMP NOT NULL,
	diagnosis VARCHAR(100)
);

INSERT INTO visit_to_doc (doctor, patient, visit_time, diagnosis)
VALUES 	(1, 1, NOW(), 'Laziness'),
		(1, 2, CURRENT_TIMESTAMP, 'Parkinson'),
		(1, 2, TO_TIMESTAMP('02/08/2017 10:59:00', 'MM/DD/YYYY HH24:MI:SS'), 'Parkinson');

/* --4. 4. Отношение "Назначения" (поля "Визит", "Назначение"). */
CREATE TABLE appoint (
	visit INT NOT NULL REFERENCES visit_to_doc (id),
	dest VARCHAR(100) NOT NULL
);

INSERT INTO appoint (visit, dest)
VALUES 	(3, 'Назначение 1'),
		(1, 'Назначение 2'),
		(2, 'Назначение 3');
