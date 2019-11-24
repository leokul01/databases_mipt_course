-- Куликов Леонид
-- 6103
-- Вариант 2

-- Л.р. №4. Изучение операций реляционной алгебры.

-- Добавляю даннные для тестирования односхемных операций РА
CREATE TABLE beg_doc (
	id SERIAL PRIMARY KEY,
	name VARCHAR(40) NOT NULL,
	post VARCHAR(40) NOT NULL,
	spec VARCHAR(60) NOT NULL,
	cab_num VARCHAR(10) NOT NULL
);

INSERT INTO beg_doc (name, post, spec, cab_num)
VALUES 	('Пупкин Василий Пупкинович', 'Хирург', 'Конечности', '14'),
		('Дронова Зинаида Васильевна', 'Терапевт', 'ОРВИ', '15'),
        ('Новиков Иоанн Сергеевич', 'Гинеколог', 'Щука', '16'),
        ('Сергеев Дмитрий Александрович', 'Стоматолог', 'Зубы', '8'),
        ('Говорун Татьяна Николаевна', 'Санитар', 'Секрет', '99'),
		('Петров Иван Генадьевич', 'Окулист', 'Яблоко', '9');


-- Унарные операции

-- Проекция
SELECT DISTINCT post, spec
FROM doc;

-- Селекция
SELECT *
FROM doc
WHERE cab_num = '14';


-- Бинарные операции

-- Декартово произведение
SELECT *
FROM doc, pat;

-- Объединение
SELECT *
FROM doc
UNION
SELECT *
FROM beg_doc;

-- Разность

-- With EXCEPT
SELECT *
FROM doc
EXCEPT
SELECT *
FROM beg_doc;

-- Without EXCEPT
SELECT *
FROM doc d
WHERE NOT EXISTS(
    SELECT *
    FROM beg_doc bd
    WHERE d.id = bd.id
    AND d.name = bd.name
    AND d.post = bd.post
    AND d.spec = bd.spec
    AND d.cab_num = bd.cab_num
);

-- Пересечение

-- With INTERSECT
SELECT *
FROM doc
INTERSECT
SELECT *
FROM beg_doc;

-- Without INTERSECT
SELECT *
FROM doc d
WHERE EXISTS(
    SELECT *
    FROM beg_doc bd
    WHERE d.id = bd.id
    AND d.name = bd.name
    AND d.post = bd.post
    AND d.spec = bd.spec
    AND d.cab_num = bd.cab_num
);

-- Соединение

-- With JOIN
SELECT *
FROM visit_to_doc v
JOIN doc d 
ON v.doctor = d.id;

-- Without JOIN
SELECT *
FROM visit_to_doc v,
     doc d
WHERE v.doctor = d.id;
